module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentTypesReader < Base

          # Build the list of content types from the folder in the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read
            self.fetch

            self.enable_relationships

            self.items
          end

          protected

          def fetch
            self.get(:content_types).each do |attributes|
              self.add(attributes)
            end
          end

          # Add a new content type in the global hash of content types.
          # If the content type exists, it returns it.
          #
          # @param [ Hash ] attributes The attributes of the content type
          #
          # @return [ Object ] A newly created content type or the existing one
          #
          def add(attributes)
            slug = attributes['slug']

            attributes.delete('entries_custom_fields').each do |_attributes|
              _attributes = _attributes.delete_if { |k, v| v.blank? || %w(id updated_at created_at).include?(k) }

              # TODO: select options

              (attributes['fields'] ||= []) << _attributes
            end

            unless self.items.key?(slug)
              self.items[slug] = Locomotive::Mounter::Models::ContentType.new(attributes)
            end

            self.items[slug]
          end

          # Make sure that each "relationship" field of a content type is
          # correctly connected to the target content type.
          def enable_relationships
            self.items.each do |_, content_type|
              content_type.fields.find_all(&:is_relationship?).each do |field|
                # look for the target content type from its slug
                field.class_name  = field.class_slug
                field.klass       = self.items[field.class_slug]
              end
            end
          end

          def safe_attributes
            %w(name slug description order_by order_direction label_field_name group_by_field_name public_submission_accounts entries_custom_fields klass_name created_at updated_at)
          end

        end

      end
    end
  end
end