module Locomotive
  module Mounter
    module Models

      class ContentEntry < Base

        ## fields ##
        field :_slug,               localized: true
        field :_position,           default: 0
        field :_visible,            default: true
        field :seo_title,           localized: true
        field :meta_keywords,       localized: true
        field :meta_description,    localized: true

        field :content_type,        association: true

        attr_accessor :dynamic_attributes, :main_locale, :errors

        alias :_permalink :_slug
        alias :_permalink= :_slug=

        ## callbacks ##
        set_callback :initialize, :after, :set_slug
        set_callback :initialize, :after, :set_default_main_locale

        ## methods ##

        # Return the internal label used to identify a content entry
        # in a YAML file for instance. It is based on the first field
        # of the related content type.
        #
        # @return [ String ] The internal label
        #
        def _label
          field = self.content_type.label_field
          value = self.dynamic_getter(field.name)

          if field.type == :belongs_to
            value.try(:_label)
          else
            value
          end
        end

        # Process a minimal validation by checking if the required fields
        # are filled in or not.
        #
        # @return [ Boolean ] False if one of the required fields is missing.
        #
        def valid?
          self.errors = []
          self.content_type.fields.each do |field|
            if field.required
              if self.dynamic_getter(field.name).blank?
                self.errors << field.name
              end
            end
          end
          self.errors.blank?
        end

        # Return the list of the fields defined in the content type
        # for which there is a value assigned.
        #
        # @return [ Array ] The list of fields
        #
        def dynamic_fields
          self.dynamic_attributes.keys.map do |name|
            self.content_type.find_field(name)
          end
        end

        # Loop over the list of dynamic fields defined in
        # the content type for which there is a value assigned.
        #
        # @example: each_dynamic_field { |field, value| .... }
        #
        def each_dynamic_field(&block)
          return unless block_given?

          self.dynamic_fields.each do |field|
            value = self.localized_dynamic_attribute_value(field)

            # value = (self.dynamic_attributes || {})[field.name.to_sym]
            # value = value.try(:[], Locomotive::Mounter.locale) unless field.is_relationship? || !field.localized

            block.call(field, value)
          end
        end

        # Determine if field passed in parameter is one of the dynamic fields.
        #
        # @param [ String/Symbol ] name Name of the dynamic field
        #
        # @return [ Boolean ] True if it is a dynamic field
        #
        def is_dynamic_field?(name)
          name = name.to_s.gsub(/\=$/, '').to_sym
          !self.content_type.find_field(name).nil?
        end

        # Return the value of a dynamic field and cast it depending
        # on the type of the field (string, date, belongs_to, ...etc).
        #
        # @param [ String/Symbol ] name Name of the dynamic field
        #
        # @return [ Object ] The casted value (String, Date, ContentEntry, ...etc)
        #
        def dynamic_getter(name)
          field = self.content_type.find_field(name)

          value = self.localized_dynamic_attribute_value(field)

          case field.type
          when :string, :text, :select, :boolean, :category
            value
          when :date
            value.is_a?(String) ? Date.parse(value) : value
          when :file
            { 'url' => value }
          when :belongs_to
            field.klass.find_entry(value)
          when :has_many
            field.klass.find_entries_by(field.inverse_of, [self._label, self._permalink])
          when :many_to_many
            field.klass.find_entries_among(value)
          end
        end

        # Set the value of a dynamic field. If the value is a hash,
        # it assumes that it represents the translations.
        #
        # @param [ String/Symbol ] name Name of the dynamic field
        # @param [ Object ] value Value to set
        #
        def dynamic_setter(name, value)
          self.dynamic_attributes ||= {}
          self.dynamic_attributes[name.to_sym] ||= {}

          field = self.content_type.find_field(name)

          if value.is_a?(Hash) # already localized
            value.keys.each { |locale| self.add_locale(locale) }
            self.dynamic_attributes[name.to_sym].merge!(value.symbolize_keys)
          else
            if field.is_relationship? || !field.localized
              self.dynamic_attributes[name.to_sym] = value
            else
              self.add_locale(Locomotive::Mounter.locale)
              self.dynamic_attributes[name.to_sym][Locomotive::Mounter.locale] = value
            end
          end
        end

        # The magic of dynamic fields happens within this method.
        # It calls the getter/setter of a dynamic field if it is one of them.
        def method_missing(name, *args, &block)
          if self.is_dynamic_field?(name)
            if name.to_s.ends_with?('=')
              name = name.to_s.gsub(/\=$/, '').to_sym
              self.dynamic_setter(name, args.first)
            else
              self.dynamic_getter(name)
            end
          else
            super
          end
        end

        # Returns a hash with the label_field value as the key and the other fields as the value
        #
        # @param [ Boolean ] nested True to have a hash of hash (whose key is the label)
        #
        # @return [ Hash ] A simple hash (nested to false) or a hash of hash
        #
        def to_hash(nested = true)
          # no need of _position and _visible (unless it's false)
          hash = super.delete_if { |k, v| k == '_position' || (k == '_visible' && v == true) }

          # also no need of the content type
          hash.delete('content_type')

          # dynamic attributes
          hash.merge!(self.dynamic_attributes.deep_stringify_keys)

          # no need of the translation of the field name in the current locale
          label_field = self.content_type.label_field

          if label_field.localized && !hash[label_field.name].empty?
            hash[label_field.name].delete(Locomotive::Mounter.locale.to_s)

            hash.delete(label_field.name) if hash[label_field.name].empty?
          end

          nested ? { self._label => hash } : hash
        end

        # Return the main default params used for the API, meaning all except
        # the dynamic fields which have to be defined outside the model.
        #
        # @return [ Hash ] The params
        #
        def to_params
          self.filter_attributes %w(_slug _position _visible seo_title meta_keywords meta_description)
        end

        def to_s
          "#{self.content_type.slug} / #{self._slug}"
        end

        protected

        # Sets the slug of the instance by using the value of the highlighted field
        # (if available). If a sibling content instance has the same permalink then a
        # unique one will be generated.
        # It applies that to every translated version of the content entry.
        def set_slug
          self.translated_in.each do |locale|
            Locomotive::Mounter.with_locale(locale) do
              # first attempt from the label
              if self._slug.blank?
                self._slug = self._label.try(:dup)
              end

              # from the content type itself
              if self._slug.blank?
                self._slug = self.content_type.send(:label_to_slug)
              end

              self._slug.permalink!

              self._slug = self.next_unique_slug if self.slug_already_taken?
            end
          end
        end

        # Once the entry has been initialized, we keep track of the current locale
        #
        def set_default_main_locale
          self.main_locale = Locomotive::Mounter.locale
        end

        # Return the next available unique slug as a string
        #
        # @return [ String] An unique permalink (or slug)
        #
        def next_unique_slug
          slug        = self._slug.gsub(/-\d*$/, '')
          next_number = 0

          self.content_type.entries.each do |entry|
            if entry._permalink =~ /^#{slug}-?(\d*)$/i
              next_number = $1.to_i if $1.to_i > next_number
            end
          end

          [slug, next_number + 1].join('-')
        end

        def slug_already_taken?
          entry = self.content_type.find_entry(self._slug)
          entry.try(:_slug) == self._slug
        end

        # Return the value of a dynamic attribute specified by its
        # corresponding content field.
        # If that attribute is localized and in the current locale
        # its value is nil, it returns the value in the main locale.
        #
        # @param [ Object ] The content field
        #
        # @return [ Object ] The value
        #
        def localized_dynamic_attribute_value(field)
          value = (self.dynamic_attributes || {})[field.name.to_sym]

          # puts "[#{field.name.inspect}] #{value.inspect} / #{field.localized.inspect} / #{value.is_a?(Hash).inspect}"

          if !field.is_relationship? && field.localized && value.is_a?(Hash)
            # get the localized value for the current locale
            _value = value[Locomotive::Mounter.locale]

            # puts "[#{field.name}] _value = #{value.inspect} / current #{Locomotive::Mounter.locale.inspect} / main #{self.main_locale.inspect}"

            # no value for the current locale, give a try to the main one
            if _value.nil? && Locomotive::Mounter.locale != self.main_locale
              _value = value[self.main_locale]
            end

            value = _value
          end

          value #.tap { |v| puts "[#{field.name}] returning #{v.inspect}" }
        end

      end

    end
  end
end