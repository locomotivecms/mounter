module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class SnippetsWriter < Base

          # It creates the config folder
          def prepare
            self.create_folder 'app/views/snippets'
          end

          # It writes all the snippets into files
          def write
            self.mounting_point.snippets.each do |filepath, snippet|
              # Note: we assume the current locale is the default one
              snippet.translated_in.each do |locale|
                default_locale = locale.to_sym == self.mounting_point.default_locale.to_sym

                Locomotive::Mounter.with_locale(locale) do
                  self.write_snippet_to_fs(snippet, filepath, default_locale ? nil : locale)
                end
              end
            end
          end

          protected

          # Write into the filesystem the file which stores the snippet template
          # The file is localized meaning a same snippet could generate a file for each translation.
          #
          # @param [ Object ] snippet The snippet
          # @param [ String ] filepath The path to the file
          # @param [ Locale ] locale The locale, nil if default locale
          #
          #
          def write_snippet_to_fs(snippet, filepath, locale)
            _filepath = "#{filepath}.liquid"
            _filepath.gsub!(/.liquid$/, ".#{locale}.liquid") if locale

            unless snippet.template_filepath.blank?
              _filepath = File.join('app', 'views', 'snippets', _filepath)

              self.open_file(_filepath) do |file|
                file.write(snippet.template)
              end
            end
          end

        end

      end
    end
  end
end