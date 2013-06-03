module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentEntriesReader < Base

          attr_accessor :ids, :relationships

          def initialize(runner)
            self.ids, self.relationships = {}, []
            super
          end

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read
            self.fetch

            self.resolve_relationships

            self.items
          end

          protected

          def fetch
            self.mounting_point.content_types.each do |slug, content_type|
              entries = self.get("content_types/#{slug}/entries", nil, true)

              entries.each do |attributes|
                locales = attributes.delete('translated_in') || []

                entry = self.add(content_type, attributes)

                # get all the translated versions
                locales.each do |locale|
                  _attributes = self.get("content_types/#{slug}/entries/#{entry._id}", locale, true)

                  Locomotive::Mounter.with_locale(locale) do
                    self.filter_attributes(content_type, _attributes).each do |key, value|
                      entry.send(:"#{key}=", value)
                    end
                  end
                end
              end
            end
          end

          # Add a content entry for a content type.
          #
          # @param [ Object ] content_type The content type
          # @param [ Hash ] attributes The attributes of the content entry
          #
          # @return [ Object] The newly created content entry
          #
          def add(content_type, attributes)
            _attributes = self.filter_attributes(content_type, attributes)

            # puts "_attributes = #{_attributes.inspect}" # DEBUG

            entry = content_type.build_entry(_attributes)

            key = File.join(content_type.slug, entry._slug)

            self.items[key] = self.ids[entry._id] = entry
          end

          # Filter the attributes coming directly from an API call.
          #
          # @param [ Object ] content_type The content type
          # @param [ Hash ] attributes The attributes of the content entry
          #
          # @return [ Object] The attributes understandable by the content entry
          #
          def filter_attributes(content_type, original_attributes)
            attributes = original_attributes.clone.keep_if { |k, v| %w(_id _slug seo_title meta_keywords meta_description _position created_at updated_at).include?(k) }

            content_type.fields.each do |field|
              value = (case field.type
              when
                original_attributes[field.name]
              when :text
                replace_urls_by_content_assets(original_attributes[field.name])
              when :select
                field.find_select_option(original_attributes[field.name]).try(:name)
              when :date
                original_attributes["formatted_#{field.name}"]
              when :file
                retrieve_file_path(content_type, field, original_attributes)
              when :belongs_to, :many_to_many
                # push a relationship in the waiting line in order to be resolved at last
                target_field_name = field.type == :belongs_to ? "#{field.name}_id" : "#{field.name}_ids"
                self.relationships << { id: attributes['_id'], field: field.name, target_ids: original_attributes[target_field_name] }
                nil
              else
                # :string, :boolean, :email, :integer, :float, :tags
                original_attributes[field.name]
              end)

              attributes[field.name] = value unless value.nil?
            end

            attributes
          end

          # Some entries have what it is called "relationships" field
          # which can be only resolved once all the entries have been fetched
          #
          def resolve_relationships
            self.relationships.each do |relationship|
              source_entry, target_ids = self.ids[relationship[:id]], relationship[:target_ids]

              target_entries = self.ids.select { |k, _| [*target_ids].include?(k) }.values

              # single entry (belongs_to) or an array (many_to_many) ?
              target_entries = target_entries.first unless target_ids.is_a?(Array)

              source_entry.send(:"#{relationship[:field]}=", target_entries)
            end
          end

          # For a given content, parse it and replace all the urls from content assets
          # by their corresponding locale ones.
          #
          # @param [ String ] content The content to parse
          #
          # @return [ String ] The content with local urls
          #
          def replace_urls_by_content_assets(content)
            return "" unless content
            self.mounting_point.content_assets.each do |path, asset|
              content.gsub!(path, asset.local_filepath)
            end
            content
          end

          def retrieve_file_path(content_type, field, attributes)
            value = attributes[field.name]

            return nil if value.blank?

            base_folder = File.join('/', 'samples', content_type.slug, attributes['_slug'])

            if value.is_a?(Hash)
              {}.tap do |translations|
                value.each do |locale, url|
                  translations[locale] = self.add_content_asset(url, File.join(base_folder, locale))
                end
              end
            else
              self.add_content_asset(value, base_folder)
            end
          end

        end

      end
    end
  end
end