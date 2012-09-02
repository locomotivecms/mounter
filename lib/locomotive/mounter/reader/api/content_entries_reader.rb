module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentEntriesReader < Base

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read
            self.fetch

            self.items
          end

          protected

          def fetch
            self.mounting_point.content_types.each do |slug, content_type|
              entries = [{"id"=>"5043da7c02c9a41325000003", "_id"=>"5043da7c02c9a41325000003", "created_at"=>"2012-09-03T00:15:24+02:00", "updated_at"=>"2012-09-03T00:15:24+02:00", "place"=>"Avogadro's Number", "formatted_date"=>"06/01/2012", "city"=>"Fort Collins", "state"=>"Colorado", "_label"=>"Avogadro's Number", "_slug"=>"avogadros-number", "_position"=>1, "content_type_slug"=>"events", "select_custom_fields"=>[], "file_custom_fields"=>[], "has_many_custom_fields"=>[], "many_to_many_custom_fields"=>[], "safe_attributes"=>["place", "formatted_date", "city", "state", "_slug", "seo_title", "meta_keywords", "meta_description", "_destroy"]}]
              # entries = self.get("content_types/#{slug}/entries", nil, true)

              puts entries.inspect

              # self.add(content_type, _attributes, index)

              raise 'STOP'
            end
          end

          # Add a content entry for a content type.
          #
          # @param [ Object ] content_type The content type
          # @param [ Hash ] attributes The attributes of the content entry
          # @param [ Integer ] position The position of the entry in the list
          #
          def add(content_type, attributes, position)
            # label, _attributes = attributes.keys.first, attributes.values.first
            #
            # # check if the label_field is localized or not
            # label_field_name = content_type.label_field_name
            #
            # if content_type.label_field.localized && _attributes.key?(label_field_name) && _attributes[label_field_name].is_a?(Hash)
            #   _attributes[label_field_name].merge!(Locomotive::Mounter.locale => label).symbolize_keys!
            # else
            #   _attributes[label_field_name] = label
            # end
            #
            # _attributes[:_position] = position
            #
            # entry = content_type.build_entry(_attributes)
            #
            # key = File.join(content_type.slug, entry._slug)
            #
            # self.items[key] = entry
          end

        end

      end
    end
  end
end