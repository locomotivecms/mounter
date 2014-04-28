module Locomotive
  module Mounter
    class Collection
      attr_reader :items

      def initialize(base_items = nil)
        @items = base_items || {}
      end

      def method_missing(method, *args)
        Query.new(self).__send__(method, *args)
      end

      def clear
        @items = {}
      end

      def []=(slug, item)
        @items[slug] = item
      end

      def find_all(&block)
        all.find_all(&block)
      end

    end

    class Query

      def initialize(collection)
        @collection = collection
        @conditions = []
        @orders = nil
        @limit = nil
        @offset = 0
      end

      def where(conditions)
        @conditions += build_conditions(conditions)
        self
      end


      def order_by(order_pairs)
        @orders = order_pairs.split.map(&:to_sym) unless order_pairs.blank?
        self
      end

      def all
        filtered
      end

      def any
        all.any?
      end

      def first
        all.first
      end

      def last
        all.last
      end

      def size
        all.size
      end

      def key? key
        all.key? key
      end

      def ==(other)
        if other.kind_of? Array
          all == other
        else
          super
        end
      end

      alias :length :size
      alias :count :size

      def each
        yield all.each.next
      end

      def [](slug)
        filtered[slug]
      end

      private

      def build_conditions(conditions)
        _conditions = conditions.clone.delete_if { |k, _| %w(order_by per_page page).include?(k) }
        _order = conditions['order_by']

        # build the chains of conditions
        _conditions.map { |name, value| Condition.new(name, value) }
      end

      def filtered
        # get only the entries matching ALL the conditions
        _entries = @collection.items.values.find_all do |content|
          accepted = true

          @conditions.each do |_condition|
            unless _condition.matches?(content)
              accepted = false
              break # no to go further
            end
          end

          accepted
        end
        ordered(_entries)
      end

      def ordered(entries)
        return entries if @orders.blank?

        name, direction  = @orders.first, (@orders.last || :asc)
        if direction == :asc
          entries.sort { |a, b| a.send(name) <=> b.send(name) }
        else
          entries.sort { |a, b| b.send(name) <=> a.send(name) }
        end
      end

    end
    class Condition

      OPERATORS = %w(all gt gte in lt lte ne nin size)

      attr_accessor :name, :operator, :right_operand

      def initialize(name, value)
        self.name, self.right_operand = name, value

        self.process_right_operand

        # default value
        self.operator = :==

        self.decode_operator_based_on_name
      end

      def matches?(entry)
        value = self.get_value(entry)

        self.decode_operator_based_on_value(value)

        case self.operator
        when :==      then value == self.right_operand
        when :ne      then value != self.right_operand
        when :matches then self.right_operand =~ value
        when :gt      then value > self.right_operand
        when :gte     then value >= self.right_operand
        when :lt      then value < self.right_operand
        when :lte     then value <= self.right_operand
        when :size    then value.size == self.right_operand
        when :all     then [*self.right_operand].contains?(value)
        when :in, :nin
          _matches = if value.is_a?(Array)
            [*value].contains?([*self.right_operand])
          else
            [*self.right_operand].include?(value)
          end
          self.operator == :in ? _matches : !_matches
        else
          raise UnknownConditionInScope.new("#{self.operator} is unknown or not implemented.")
        end
      end

      def to_s
        "#{name} #{operator} #{self.right_operand.to_s}"
      end

      protected

      def get_value(entry)
        value = entry.send(self.name)

        if value.respond_to?(:_slug)
          # belongs_to
          value._slug
        elsif value.respond_to?(:map)
          # many_to_many or tags ?
          value.map { |v| v.respond_to?(:_slug) ? v._slug : v }
        else
          value
        end
      end

      def process_right_operand
        if self.right_operand.respond_to?(:_slug)
          # belongs_to
          self.right_operand = self.right_operand._slug
        elsif self.right_operand.respond_to?(:map) && self.right_operand.first.respond_to?(:_slug)
          # many_to_many
          self.right_operand = self.right_operand.map do |entry|
            entry.try(&:_slug)
          end
        end
      end

      def decode_operator_based_on_name
        if name =~ /^([a-z0-9_-]+)\.(#{OPERATORS.join('|')})$/
          self.name     = $1.to_sym
          self.operator = $2.to_sym
        end

        if self.right_operand.is_a?(Regexp)
          self.operator = :matches
        end
      end

      def decode_operator_based_on_value(value)
        case value
        when Array
          self.operator = :in if self.operator == :==
        end
      end
    end
  end
end
