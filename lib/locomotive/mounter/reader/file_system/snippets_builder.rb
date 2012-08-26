module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class SnippetsBuilder < Base

          # Build the list of snippets from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of snippets
          #
          def build
            self.fetch_from_filesystem

            self.items
          end

          protected

          # Record snippets found in file system
          def fetch_from_filesystem
            Dir.glob(File.join(self.root_dir, "*.{#{Locomotive::Mounter::TEMPLATE_EXTENSIONS.join(',')}}")).each do |filepath|
              fullpath = File.basename(filepath)

              snippet = self.add(filepath)

              Locomotive::Mounter.with_locale(self.filepath_locale(filepath)) do
                snippet.template = Tilt.new(filepath)
              end
            end
          end

          # Return the directory where all the templates of
          # snippets are stored in the filesystem.
          #
          # @return [ String ] The snippets directory
          #
          def root_dir
            File.join(self.runner.path, 'app', 'views', 'snippets')
          end

          # Add a new snippet in the global hash of snippets.
          # If the snippet exists, it returns it.
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ Object ] A newly created snippet or the existing one
          #
          def add(filepath)
            slug = self.filepath_to_slug(filepath)

            unless self.items.key?(slug)
              self.items[slug] = Locomotive::Mounter::Models::Snippet.new({
                name:     slug.humanize,
                slug:     slug,
                template: Tilt.new(filepath)
              })
            end

            self.items[slug]
          end

          # Convert a filepath to a slug
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ String ] The slug
          #
          def filepath_to_slug(filepath)
            File.basename(filepath).split('.').first
          end

        end

      end
    end
  end
end
