module Locomotive
  module Mounter

    module Fields

      extend ActiveSupport::Concern

      included do
        cattr_accessor :_fields
        self._fields = {}
      end

      def write_attributes(attributes)
        return if attributes.blank?

        attributes.each do |name, value|
          unless self.class._fields.key?(name.to_sym)
            Locomotive::Mounter.logger.warn "[#{self.class.inspect}] setting an unknown attribute '#{name}' with the value '#{value.inspect}'"
            raise FieldDoesNotExistException.new "The '#{name}' field does not exist"
          end

          if self.localized?(name) && value.is_a?(Hash)
            self.send(:"#{name}_translations=", value)
          else
            self.send(:"#{name}=", value)
          end
        end
      end

      def localized?(name)
        self.send :"#{name}_localized?"
      end

      protected

      def getter(name, localized = false)
        value = self.instance_variable_get(:"@#{name}")
        if localized
          (value || {})[I18n.locale]
        else
          value
        end
      end

      def setter(name, value, localized = false)
        if localized
          translations = self.instance_variable_get(:"@#{name}") || {}
          translations[I18n.locale] = value
          value = translations
        end
        self.instance_variable_set(:"@#{name}", value)
      end

      module ClassMethods

        def field(name, options = {})
          options = { localized: false }.merge(options)

          self._fields[name] = options

          class_eval <<-EOV
            def #{name}
              self.getter '#{name}', #{options[:localized]}
            end

            def #{name}=(value)
              self.setter '#{name}', value, #{options[:localized]}
            end

            def #{name}_localized?
              #{options[:localized]}
            end
          EOV

          if options[:localized]
            class_eval <<-EOV
              def #{name}_translations
                @#{name} || {}
              end

              def #{name}_translations=(translations)
                @#{name} = translations
              end
            EOV
          end
        end

      end

    end
  end
end