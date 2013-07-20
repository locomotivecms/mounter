module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class PagesWriter < Base

          # It creates the pages folder
          def prepare
            super
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
            self.output_resource_op page

            # Note: we assume the current locale is the default one
            page.translated_in.each do |locale|
              default_locale = locale.to_sym == self.mounting_point.default_locale.to_sym

              # we do not need the localized version of the filepath
              filepath = page.fullpath.dasherize

              Locomotive::Mounter.with_locale(locale) do
                # we assume the filepath is already localized
                self.write_page_to_fs(page, filepath, default_locale ? nil : locale)
              end
            end

            self.output_resource_op_status page

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
            # puts filepath.inspect
            _filepath = "#{filepath}.liquid"
            _filepath.gsub!(/.liquid$/, ".#{locale}.liquid") if locale

            _filepath = File.join('app', 'views', 'pages', _filepath)

            self.replace_content_asset_urls(page.source)

            self.open_file(_filepath) do |file|
              file.write(page.to_yaml)
            end
          end

          # The content assets on the remote engine follows the format: /sites/<id>/assets/<type>/<file>
          # This method replaces these urls by their local representation. <type>/<file>
          #
          # @param [ String ] content The text where the assets will be replaced.
          #
          def replace_content_asset_urls(content)
            return if content.blank?
            content.force_encoding('utf-8').gsub!(/[("']\/sites\/[0-9a-f]{24}\/assets\/(([^;.]+)\/)*([a-zA-Z_\-0-9]+)\.[a-z]{2,3}[)"']/) do |path|
              "/#{$3}"
            end
          end

        end

      end
    end
  end
end