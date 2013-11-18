module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class SnippetsReader < Base

          # Build the list of snippets from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of snippets
          #
          def read
            self.fetch_from_filesystem

            self.set_default_template_for_each_locale

            self.items
          end

          protected

          # Record snippets found in file system
          def fetch_from_filesystem
            Dir.glob(File.join(self.root_dir, "*.{#{Locomotive::Mounter::TEMPLATE_EXTENSIONS.join(',')}}")).each do |filepath|
              fullpath = File.basename(filepath)

              snippet = self.add(filepath)

              Locomotive::Mounter.with_locale(self.filepath_locale(filepath)) do
                snippet.template = self.fetch_template(filepath)
              end
            end
          end

          # Set a default template (coming from the default locale)
          # for each snippet which does not have a translated version
          # of the template in each locale.
          #
          def set_default_template_for_each_locale
            self.items.values.each do |snippet|
              default_template = snippet.template

              next if default_template.blank?

              self.locales.map(&:to_sym).each do |locale|
                next if locale == self.default_locale

                _template = snippet.template_translations[locale]

                if !_template.is_a?(Exception) && _template.blank?
                  snippet.template_translations[locale] = default_template
                end
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
                template: self.fetch_template(filepath)
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
            File.basename(filepath).split('.').first.permalink(true)
          end

          # From a filepath, parse the template inside.
          # and return the related Tilt instance.
          # It may return the exception if the template is invalid
          # (only for HAML templates).
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ Object ] The Tilt template or the exception itself if the template is invalid
          #
          def fetch_template(filepath)
            Locomotive::Mounter::Utils::YAMLFrontMattersTemplate.new(filepath)
          end

        end

      end
    end
  end
end
