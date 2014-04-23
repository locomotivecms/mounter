module Locomotive
  module Mounter
    class Collection

      def initialize(base_items = nil)
        @items = base_items || {}
      end

      def all
        @items.values
      end

      def find_all(&block)
        all.find_all(&block)
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
        @items.key? key
      end

      def clear
        @items = {}
      end

      alias :length :size
      alias :count :size

      def where(conditions)
        _conditions = conditions.clone.delete_if { |k, _| %w(order_by per_page page).include?(k) }

        # build the chains of conditions
        conditions_hash = _conditions.map { |name, value| Condition.new(name, value) }

        # get only the entries matching ALL the conditions
        _entries = find_all do |content|
          accepted = true

          conditions_hash.each do |_condition|
            unless _condition.matches?(content)
              accepted = false
              break # no to go further
            end
          end

          accepted
        end
        Collection.new(_entries)
      end

      def each
        yield all.each.next
      end

      def [](slug)
        @items[slug]
      end
      def []=(slug, item)
        @items[slug] = item
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
