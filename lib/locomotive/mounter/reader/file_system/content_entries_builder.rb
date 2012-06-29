module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentEntriesBuilder < Base

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def build
            self.fetch_from_filesystem

            self.items
          end

          protected

          def fetch_from_filesystem
            Dir.glob(File.join(self.root_dir, '*.yml')).each do |filepath|
              attributes = self.read_yaml(filepath)

              content_type = self.get_content_type(File.basename(filepath, '.yml'))

              attributes.each_with_index do |_attributes, index|
                self.add(content_type, _attributes.merge(position: index))
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
          #
          def add(content_type, attributes)
            label, _attributes = attributes.keys.first, attributes.values.first

            _attributes[content_type.label_field_name] = label

            entry = content_type.build_entry(_attributes)

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