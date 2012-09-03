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
        field :localized, default: false

        # text
        field :text_formatting

        # select
        field :select_options

        # relationships: belongs_to, has_many, many_to_many
        field :class_name
        field :inverse_of
        field :order_by
        field :ui_enabled

        alias :target :class_name
        alias :target= :class_name=

        ## callbacks ##
        set_callback :initialize, :after, :prepare_attributes

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

        # Return the name of the select option described by its id AND
        # for the current locale.
        # Works only for the select type.
        #
        # @param [ String ] id Identifier of the option (BSON::ObjectId)
        #
        # @return [ String ] The value of the select option. Nil if not found
        #
        def name_for_select_option(id)
          translations = (self.select_options || []).find { |hash| hash['_id'] == id }
          (translations || {})[Locomotive::Mounter.locale.to_s]
        end

        # Instead of returning a simple hash, it returns a hash with name as the key and
        # the remaining attributes as the value.
        #
        # @return [ Hash ] A hash of hash
        #
        def to_hash
          hash = super.delete_if { |k, v| %w(name position).include?(k) }
          { self.name => hash }
        end

        protected

        # Clean up useless properties depending on its type
        def sanitize
          # ui_enabled only for the belongs_to, has_many and many_to_many types
          self.ui_enabled = nil unless self.is_relationship?

          # text_formatting only for the text type
          self.text_formatting = nil unless self.type == :text

          # select_options only for the select type
          self.select_options = nil unless self.type == :select
        end

      end

    end
  end
end