module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentTypesBuilder < Base

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def build
            self.fetch_content_types_from_filesystem

            self.items
          end

          protected

          def fetch_content_types_from_filesystem
            Dir.glob(File.join(self.content_types_dir, '*.yml')).each do |filepath|
              attributes = self.read_yaml(filepath)

              self.add_content_type(attributes)
            end
          end

          # Add a new content type in the global hash of content types.
          # If the content type exists, it returns it.
          #
          # @param [ Hash ] attributes The attributes of the content type
          #
          # @return [ Object ] A newly created content type or the existing one
          #
          def add_content_type(attributes)
            slug = attributes['slug']

            attributes.delete('fields').each_with_index do |_attributes, index|
              hash = { name: _attributes.keys.first, position: index }.merge(_attributes.values.first)
              (attributes['fields'] ||= []) << hash
            end

            unless self.items.key?(slug)
              self.items[slug] = Locomotive::Mounter::Models::ContentType.new(attributes)
            end

            self.items[slug]
          end

          # Return the directory where all the definition of
          # the conten types are stored.
          #
          # @return [ String ] The content types directory
          #
          def content_types_dir
            File.join(self.runner.path, 'app', 'content_types')
          end

        end

      end
    end
  end
end