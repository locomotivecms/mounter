module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentEntriesReader < Base

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read
            self.fetch_from_filesystem

            self.items
          end

          protected

          def fetch_from_filesystem
            Dir.glob(File.join(self.root_dir, '*.yml')).each do |filepath|
              attributes = self.read_yaml(filepath)

              content_type = self.get_content_type(File.basename(filepath, '.yml'))

              content_type.entries.try(:clear)

              attributes.each_with_index do |_attributes, index|
                self.add(content_type, _attributes, index)
              end
            end
          end

          # Get the content type identified by the slug from the mounting point.
          # Raise an UnknownContentTypeException exception if such a content type
          # does not exist.
          #
          # @param [ String ] slug The slug of the content type
          #
          # @return [ Object ] The instance of the content type
          #
          def get_content_type(slug)
            self.mounting_point.content_types[slug.to_s].tap do |content_type|
              if content_type.nil?
                raise UnknownContentTypeException.new("unknow content type #{slug.inspect}")
              end
            end
          end

          # Add a content entry for a content type.
          #
          # @param [ Object ] content_type The content type
          # @param [ Hash ] attributes The attributes of the content entry
          # @param [ Integer ] position The position of the entry in the list
          #
          def add(content_type, attributes, position)
            if attributes.is_a?(String)
              label, _attributes = attributes, {}
            else
              label, _attributes = attributes.keys.first, attributes.values.first
            end

            # check if the label_field is localized or not
            label_field_name = content_type.label_field_name

            if content_type.label_field.localized && _attributes.key?(label_field_name) && _attributes[label_field_name].is_a?(Hash)
              _attributes[label_field_name].merge!(Locomotive::Mounter.locale => label).symbolize_keys!
            else
              _attributes[label_field_name] = label
            end

            _attributes[:_position] = position

            entry = content_type.build_entry(_attributes)

            # puts "entry._slug = #{entry._slug.inspect}"
            # entry.main_locale = Locomotive::Mounter.locale
            # puts entry.to_hash.inspect
            # puts entry.dynamic_attributes.inspect
            # puts entry.send(:sync_translations)

            key = File.join(content_type.slug, entry._slug)

            self.items[key] = entry
          end

          # Return the directory where all the entries
          # of the content types are stored.
          #
          # @return [ String ] The content entries root directory
          #
          def root_dir
            File.join(self.runner.path, 'data')
          end

        end

      end
    end
  end
end