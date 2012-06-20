module Locomotive
  module Mounter

    module Fields

      extend ActiveSupport::Concern

      included do
        cattr_accessor :_fields
        self._fields = {}

        attr_accessor :_locales
      end

      # Set or replace the attributes of the current instance by the ones
      # passed as parameter.
      # It raises an exception if one of the keys is not included in the list of fields.
      #
      # @param [ Hash ] attributes The new attributes
      #
      def write_attributes(attributes)
        return if attributes.blank?

        attributes.each do |name, value|
          unless self.class._fields.key?(name.to_sym)
            message = "[#{self.class.inspect}] setting an unknown attribute '#{name}' with the value '#{value.inspect}'"
            Locomotive::Mounter.logger.warn message
            raise FieldDoesNotExistException.new message
          end

          if self.localized?(name) && value.is_a?(Hash)
            self.send(:"#{name}_translations=", value)
          else
            self.send(:"#{name}=", value)
          end
        end
      end

      # Check if the field specified by the argument is localized
      #
      # @param [ String ] name Name of the field
      #
      # @return [ Boolean ] True if the field is localized
      #
      def localized?(name)
        self.send :"#{name}_localized?"
      end

      # List all the translations done on that model
      #
      # @return [ List ] List of locales
      #
      def translated_in
        self._locales
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
          # keep track of the current locale
          self.add_locale(I18n.locale)

          translations = self.instance_variable_get(:"@#{name}") || {}
          translations[I18n.locale] = value
          value = translations
        end
        self.instance_variable_set(:"@#{name}", value)
      end

      def add_locale(locale)
        self._locales ||= []
        self._locales << locale.to_sym unless self._locales.include?(locale.to_sym)
      end

      module ClassMethods

        # Add a field to the current instance. It creates getter/setter methods related to that field.
        # A field can have translations if the option named localized is set to true.
        #
        # @param [ String ] name The name of the field
        # @param [ Hash ] options The options related to the field.
        #
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
                translations.each { |locale, value| self.add_locale(locale) }
                @#{name} = translations.symbolize_keys
              end
            EOV
          end
        end

      end

    end
  end
end