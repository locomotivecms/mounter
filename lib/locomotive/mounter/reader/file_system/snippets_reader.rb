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
            self.items = Collection.new self
          end

          # Returns a snippet from its slug.
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ Object ] A newly created snippet or the existing one
          #
          def fetch_one(slug)
            Locomotive::Mounter::Models::Snippet.new({
              name:     slug.humanize,
              slug:     slug,
            }).tap do |snippet|
              templates_for(slug).each do |filepath|
                Locomotive::Mounter.with_locale(filepath_locale(filepath)) do
                  snippet.template = fetch_template(filepath)
                end
              end
              set_default_template_for_each_locale snippet
            end
          end

          def all_slugs
            Dir.glob(File.join(self.root_dir, "*.{#{Locomotive::Mounter::TEMPLATE_EXTENSIONS.join(',')}}"))
              .map( &method(:filepath_to_slug) )
              .uniq
          end

          protected

          # Set a default template (coming from the default locale)
          # for each snippet which does not have a translated version
          # of the template in each locale.
          #
          def set_default_template_for_each_locale snippet
            default_template = snippet.template

            unless default_template.blank?

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


          # From a filepath, parse the template inside.
          # and return the related Tilt instance.
          # It may return the exception if the template is invalid
          # (only for HAML templates).
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ Object ] The Tilt template or the exception itself if the template is invalid
          #
          def fetch_template (filepath)
            Locomotive::Mounter::Utils::YAMLFrontMattersTemplate.new(filepath)
          end
        end
      end
    end
  end
end