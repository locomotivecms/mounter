module Locomotive
  module Mounter
    module Models

      class ContentType < Base

        ## fields ##
        field :name
        field :description
        field :slug
        field :label_field_name
        field :group_by
        field :order_by
        field :order_direction
        field :public_submission_enabled
        field :public_submission_accounts
        field :raw_item_template

        field :fields, type: :array, class_name: 'Locomotive::Mounter::Models::ContentField'

        field :entries, association: true

        ## callbacks ##
        set_callback :initialize, :after, :sanitize

        ## other accessors ##
        attr_accessor :klass_name, :group_by_field_id

        ## aliases ##
        alias_method :group_by_field_name, :group_by
        alias_method :group_by_field_name=, :group_by=

        ## methods ##

        # Return the label field (by the default the first field)
        #
        # @return [ Object ] The label field
        #
        def label_field
          self.find_field(self.label_field_name) || self.fields.first
        end

        # Return the group_by field
        #
        # @return [ Object ] The group_by field
        #
        def group_by_field
          self.fields.find_field(self.group_by_field_name)
        end

        # Build a content entry and add it to the list of entries of the content type.
        # The content type will be referenced into the newly built entry .
        #
        # @param [ Hash ] attributes Attributes of the new content entry
        #
        # @return [ Object ] The newly built content entry
        #
        def build_entry(attributes)
          ContentEntry.new(content_type: self).tap do |entry|
            # do not forget that we are manipulating dynamic fields
            attributes.each { |k, v| entry.send(:"#{k}=", v) }

            entry._slug ||= self.label_to_slug(entry._label)

            (self.entries ||= []) << entry
          end
        end

        # Tell if the content type owns a field which defines
        # a relationship to another content type.
        #
        # @return [ Boolean ] True if a relationship field exists
        #
        def with_relationships?
          self.fields.any? { |field| field.is_relationship? }
        end

        # Return the list of fields which do not describe
        # a relationship.
        #
        # @return [ Array ] The list of fields.
        #
        def non_relationship_fields
          self.fields.select { |field| !field.is_relationship? }
        end

        # Find a field by its name (string or symbol) or its id (API)
        #
        # @param [ String / Symbol] name_or_id Name or Id of the field
        #
        # @return [ Object ] The field if it exists or nil
        #
        def find_field(name_or_id)
          self.fields.detect { |field| field.name.to_s == name_or_id.to_s || field._id == name_or_id }
        end

        # Find a content entry by its ids (ie: _permalink or _label)
        #
        # @param [ String ] id A permalink or a label
        #
        # @return [ Object ] The content entry if it exists or nil
        #
        def find_entry(id)
          (self.entries || []).detect { |entry| [entry._permalink, entry._label].include?(id) }
        end

        # Find all the entries whose their _permalink or _label is among the ids
        # passed in parameter.
        #
        # @param [ Array ] ids List of permalinks or labels
        #
        # @return [ Array ] List of content entries or [] if none
        #
        def find_entries_among(ids)
          (self.entries || []).find_all { |entry| [*ids].any? { |v| [entry._permalink, entry._label].include?(v) } }
        end

        # Find all the entries by a field and its value.
        #
        # @param [ String ] name Name of the field
        # @param [ String / Array ] value The different value of the field to test
        #
        # @return [ Array ] List of content entries or [] if none
        #
        def find_entries_by(name, value)
          (self.entries || []).find_all { |entry| [*value].include?(entry.send(name.to_sym)) }
        end

        # Return the params used for the API.
        # The options parameter can be used to get all the fields even
        # the ones describing a relationship with another content type.
        #
        # @param [ Hash ] options Default values: { all_fields: false }
        #
        # @return [ Hash ] The params
        #
        def to_params(options = nil)
          options = { all_fields: false }.merge(options || {})

          fields = %w(name slug description label_field_name group_by_field_name order_by order_by_direction public_submission_enabled raw_item_template)

          params = self.attributes.delete_if { |k, v| !fields.include?(k.to_s) || v.blank? }.deep_symbolize_keys

          # order by
          params[:order_by] = '_position' if self.order_by == 'manually'

          # fields
          _fields = options[:all_fields] ? self.fields : self.non_relationship_fields
          params[:entries_custom_fields] = _fields.map(&:to_params)

          params
        end

        def to_s
          self.name
        end

        protected

        # Give an unique slug based on a label and within the scope of the content type.
        #
        # @param [ String ] label The label
        #
        # @return [ String ] An unique slug
        #
        def label_to_slug(label)
          base, index = label.parameterize('-'), 1
          unique_slug = base

          while self.find_entry(unique_slug)
            unique_slug = "#{base}-#{index}"
            index += 1
          end

          unique_slug
        end

        # Method used to clean up the content and its fields.
        # Besides, it also sets the values defined by other attributes.
        def sanitize
          # if no label_field_name provided, take the first field
          unless self.label_field_name
            self.label_field_name = (self.fields || []).first.try(:name)
          end

          # define group_by_field from group_by_field_id
          if self.group_by_field_id
            self.group_by_field_name = self.find_field(self.group_by_field_id)
          end

          # public_submission_accounts means public_submission_enabled set to true
          self.public_submission_enabled = true if self.public_submission_accounts.is_a?(Array)
        end

      end

    end
  end
end