module Locomotive
  module Mounter
    module Models

      class ContentField < Base

        ## fields ##
        field :label
        field :name
        field :type,      default: :string
        field :hint
        field :position,  default: 0
        field :required,  default: false
        field :unique,    default: false
        field :localized, default: false

        # text
        field :text_formatting

        # select
        field :select_options, type: :array, class_name: 'Locomotive::Mounter::Models::ContentSelectOption'

        # relationships: belongs_to, has_many, many_to_many
        field :class_slug # out
        field :class_name # in
        field :inverse_of
        field :order_by
        field :ui_enabled

        alias :target :class_name
        alias :target= :class_name=
        alias :raw_select_options= :select_options=

        ## callbacks ##
        set_callback :initialize, :after, :prepare_attributes

        ## other accessors ##
        attr_accessor :_destroy

        ## methods ##

        def prepare_attributes
          self.label ||= self.name.try(:humanize)
          self.type = self.type.to_sym
          self.sanitize
        end

        # Tell if it describes a relationship (belongs_to, many_to_many, has_many) or not.
        #
        # @return [ Boolean ] True if describing a relationship
        #
        def is_relationship?
          %w(belongs_to has_many many_to_many).include?(self.type.to_s)
        end

        # Tell if the id, the name of the field or other property based on
        # its name (like formatted_<date field>) matches the parameter.
        #
        # @param [ String / Symbol] name_or_id Name or Id of the field
        #
        # @return [ Boolean ] True if the current field matches the parameter
        #
        def matches?(id_or_name)
          default = [self._id, self.name]

          list = default + (case self.type.to_sym
          when :date, :date_time then ["formatted_#{self.name}"]
          else
            []
          end)

          list.include?(id_or_name.to_s)
        end

        # Return the content type matching the class_name / target attribute
        #
        # @return [ Object ] The matching Content Type
        #
        def klass
          (@klass ||= self.mounting_point.content_types[self.class_name]).tap do |klass|
            if klass.nil?
              raise UnknownContentTypeException.new("unknow content type #{self.class_name}")
            end
          end
        end

        # Set directly the content type matching the class_name.
        #
        # @param [ Object ] The matching Content Type
        #
        def klass=(content_type)
          if self.class_name == content_type.slug
            @klass = content_type
          end
        end

        # Find a select option by its name IN the current locale.
        #
        # @param [ String / Symbol] name_or_id Name or Id of the option
        #
        # @return [ Object ] The select option or nil if not found
        #
        def find_select_option(name_or_id)
          return nil if self.select_options.blank?
          self.select_options.detect { |option| option.name.to_s == name_or_id.to_s || option._id == name_or_id }
        end

        # Return the params used for the API.
        #
        # @return [ Hash ] The params
        #
        def to_params
          params = self.filter_attributes %w(label name type hint position required localized unique)

          # we set the _id / _destroy attributes for embedded documents
          params[:_id]      = self._id if self.persisted?
          params[:_destroy] = self._destroy if self._destroy

          case self.type
          when :text
            params[:text_formatting] = self.text_formatting
          when :select
            params[:raw_select_options] = self.select_options.map(&:to_params)
          when :belongs_to
            params[:class_name] = self.class_name
          when :has_many, :many_to_many
            %w(class_name inverse_of order_by ui_enabled).each do |name|
              params[name.to_sym] = self.send(name.to_sym)
            end
          end

          params
        end

        # Instead of returning a simple hash, it returns a hash with name as the key and
        # the remaining attributes as the value.
        #
        # @return [ Hash ] A hash of hash
        #
        def to_hash
          hash = super.delete_if { |k, v| %w(name position).include?(k) }

          # class_name is chosen over class_slug
          if self.is_relationship?
            hash['class_name'] ||= hash['class_slug']
            hash.delete('class_slug')
          end

          # select options
          if self.type == :select
            hash['select_options'] = self.select_options_to_hash
          end

          { self.name => hash }
        end

        protected

        # Clean up useless properties depending on its type
        def sanitize
          # ui_enabled only for the belongs_to, has_many and many_to_many types
          self.ui_enabled = nil unless self.is_relationship?

          # text_formatting only for the text type
          self.text_formatting = nil unless self.type == :text
        end

        def select_options_to_hash
          locales = self.select_options.map { |option| option.translated_in }.flatten.uniq
          options = self.select_options.sort { |a, b| a.position <=> b.position }

          if locales.size > 1
            {}.tap do |by_locales|
              locales.each do |locale|
                options.each do |option|
                  (by_locales[locale.to_s] ||= []) << option.name_translations[locale]
                end
              end
            end
          else
            options.map(&:name)
          end
        end

      end

    end
  end
end