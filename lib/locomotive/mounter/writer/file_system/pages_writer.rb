module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class PagesWriter < Base

          # It creates the config folder
          def prepare
            self.create_folder 'app/views/pages'
          end

          # It writes all the pages into files
          def write
            self.write_page(self.mounting_point.pages['index'])

            self.write_page(self.mounting_point.pages['404'])
          end

          protected

          # Write the information about a page into the filesystem.
          # Called itself recursively. Called at first by the write method
          #
          # @param [ Object ] page The page
          # @param [ String ] path The parent path
          #
          def write_page(page, path = '')
            # Note: we assume the current locale is the default one
            page.translated_in.each do |locale|
              default_locale = locale.to_sym == self.mounting_point.default_locale.to_sym

              filepath = (path.blank? ? page.slug : File.join(path, page.slug)).underscore

              Locomotive::Mounter.with_locale(locale) do
                self.write_page_to_fs(page, filepath, default_locale ? nil : locale)
              end
            end

            # also write the nested pages
            (page.children || []).each do |child|
              self.write_page(child, page.depth == 0 ? '' : page.slug)
            end
          end

          # Write into the filesystem the file about the page which will store
          # information about this page + template.
          # The file is localized meaning a same page could generate a file for each translation.
          #
          # @param [ Object ] page The page
          # @param [ String ] filepath The path to the file describing the page (not localized)
          # @param [ Locale ] locale The locale, nil if default locale
          #
          #
          def write_page_to_fs(page, filepath, locale)
            _filepath = "#{filepath}.liquid"
            _filepath.gsub!(/.liquid$/, ".#{locale}.liquid") if locale

            unless page.template_filepath.blank?
              _filepath = File.join('app', 'views', 'pages', _filepath)

              self.open_file(_filepath) do |file|
                file.write(page.to_yaml)
              end
            end
          end

        end

      end
    end
  end
end