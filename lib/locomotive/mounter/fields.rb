module Locomotive
  module Mounter

    module Fields

      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks

        define_callbacks :initialize

        class << self; attr_accessor :_fields end

        attr_accessor :_locales
      end

      # Default constructor
      #
      # @param [ Hash ] attributes The new attributes
      #
      def initialize(attributes = {})
        run_callbacks :initialize do
          _attributes = attributes.symbolize_keys

          # set default values
          self.class._fields.each do |name, options|
            next if !options.key?(:default) || _attributes.key?(name)

            _attributes[name] = options[:default]
          end

          # set default translation
          self.add_locale(Locomotive::Mounter.locale)

          self.write_attributes(_attributes)
        end
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
          unless self.class._fields.key?(name.to_sym) || self.respond_to?(:"#{name}=")
            next if name.to_s == 'id'
            raise FieldDoesNotExistException.new "[#{self.class.inspect}] setting an unknown attribute '#{name}' with the value '#{value.inspect}'"
          end

          if self.localized?(name) && value.is_a?(Hash)
            self.send(:"#{name}_translations=", value)
          else
            self.send(:"#{name}=", value)
          end
        end
      end

      alias :attributes= :write_attributes

      # Return the fields with their values
      #
      # @return [ Hash ] The attributes
      #
      def attributes
        {}.tap do |_attributes|
          self.class._fields.each do |name, options|
            _attributes[name] = self.send(name.to_sym)
          end
        end
      end

      # Return the fields with their values and their translations
      #
      # @return [ Hash ] The attributes
      #
      def attributes_with_translations
        {}.tap do |_attributes|
          self.class._fields.each do |name, options|
            next if options[:association]

            if options[:localized]
              value = self.send(:"#{name}_translations")

              value = value.values.first if value.size == 1

              value = nil if value.empty?

              _attributes[name] = value
            else
              _attributes[name] = self.send(name.to_sym)
            end
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
        method_name = :"#{name}_localized?"
        self.respond_to?(method_name) && self.send(method_name)
      end

      # List all the translations done on that model
      #
      # @return [ List ] List of locales
      #
      def translated_in
        self._locales.map(&:to_sym)
      end

      # Tell if the object has been translated in the locale
      # passed in parameter.
      #
      # @param [ String/Symbol ] locale
      #
      # @return [ Boolean ] True if one of the fields has been translated.
      #
      def translated_in?(locale)
        self.translated_in.include?(locale.to_sym)
      end

      # Return a Hash of all the non blank attributes of the object.
      # It also performs a couple of modifications: stringify keys and
      # convert Symbol to String.
      #
      # @param [ Boolean ] translation Flag (by default true) to get the translations too.
      #
      # @return [ Hash ] The non blank attributes
      #
      def to_hash(translations = true)
        hash = translations ? self.attributes_with_translations : self.attributes

        hash.delete_if { |k, v| v.blank? }

        hash.each { |k, v| hash[k] = v.to_s if v.is_a?(Symbol) }

        hash.deep_stringify_keys
      end

      # Provide a better output of the default to_yaml method
      #
      # @return [ String ] The YAML version of the object
      #
      def to_yaml
        # get the attributes with their translations and get rid of all the symbols
        object = self.to_hash

        object.each do |key, value|
          if value.is_a?(Array)
            object[key] = if value.first.is_a?(String)
              StyledYAML.inline(value) # inline array
            else
              value.map(&:to_hash)
            end
          end
        end

        StyledYAML.dump object
      end

      protected

      def getter(name, options = {})
        value = self.instance_variable_get(:"@#{name}")
        if options[:localized]
          (value || {})[Locomotive::Mounter.locale]
        else
          value
        end
      end

      def setter(name, value, options = {})
        if options[:localized]
          # keep track of the current locale
          self.add_locale(Locomotive::Mounter.locale)

          translations = self.instance_variable_get(:"@#{name}") || {}
          translations[Locomotive::Mounter.locale] = value
          value = translations
        end

        if options[:type] == :array
          klass = options[:class_name].constantize
          value = value.map { |object| object.is_a?(Hash) ? klass.new(object) : object }
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

          @_fields ||= {} # initialize the list of fields if nil

          self._fields[name.to_sym] = options

          class_eval <<-EOV
            def #{name}
              self.getter '#{name}', self.class._fields[:#{name}]
            end

            def #{name}=(value)
              self.setter '#{name}', value, self.class._fields[:#{name}] #, #{options[:localized]}
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