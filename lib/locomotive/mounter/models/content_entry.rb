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

        attr_accessor :dynamic_attributes

        alias :_permalink :_slug
        alias :_permalink= :_slug=

        ## callbacks ##
        # set_callback :initialize, :after, :prepare_attributes

        ## methods ##

        # Set the default attributes
        # def prepare_attributes
        #   # self._label_field_name = self.content_type.fields.first.name
        # end

        # Return the internal label used to identify a content entry
        # in a YAML file for instance. It is based on the first field
        # of the related content type.
        #
        # @return [ String ] The internal label
        #
        def _label
          name = self.content_type.label_field_name
          self.dynamic_getter(name)
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

          value = (self.dynamic_attributes || {})[name.to_sym]

          value = value.try(:[], Locomotive::Mounter.locale) unless field.is_relationship? || !field.localized

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
            self.dynamic_attributes[name.to_sym].merge!(value)
          else
            if field.is_relationship? || !field.localized
              self.dynamic_attributes[name.to_sym] = value
            else
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
        # @return [ Hash ] A hash of hash
        #
        def to_hash
          # no need of _position and _visible (unless it's false)
          hash = super.delete_if { |k, v| k == '_position' || (k == '_visible' && v == true) }

          # dynamic attributes
          hash.merge!(self.dynamic_attributes.deep_stringify_keys)

          # no need of the translation of the field name in the current locale
          label_field = self.content_type.label_field

          if label_field.localized && !hash[label_field.name].empty?
            hash[label_field.name].delete(Locomotive::Mounter.locale.to_s)

            hash.delete(label_field.name) if hash[label_field.name].empty?
          end

          { self._label => hash }
        end

      end

    end
  end
end