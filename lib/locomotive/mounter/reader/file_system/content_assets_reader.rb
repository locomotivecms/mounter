module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentAssetsReader < Base

          # Build the list of contents assets
          #
          # @return [ Array ] The list of content assets
          #
          def read
            self.items = [] # prefer an array over a hash

            self.fetch_from_pages

            self.fetch_from_content_entries

            self.items
          end

          protected

          # Fetch the files from the template of all the pages
          #
          def fetch_from_pages
            self.mounting_point.pages.values.each do |page|
              page.translated_in.each do |locale|
                Locomotive::Mounter.with_locale(locale) do
                  unless page.template.blank?
                    self.add_assets_from_string(page.source)
                  end
                end
              end
            end
          end

          # Fetch the files from the content entries
          #
          def fetch_from_content_entries
            self.mounting_point.content_entries.values.each do |content_entry|
              content_entry.translated_in.each do |locale|
                Locomotive::Mounter.with_locale(locale) do
                  # get the string, text, file fields...
                  content_entry.content_type.fields.each do |field|
                    case field.type.to_sym
                    when :string, :text
                      self.add_assets_from_string(content_entry.dynamic_getter(field.name))
                    when :file
                      self.add_assets_from_string(content_entry.dynamic_getter(field.name)['url'])
                    end
                  end
                end
              end
            end
          end

          # Parse the string passed in parameter in order to
          # look for content assets. If found, then add them.
          #
          # @param [ String ] source The string to parse
          #
          def add_assets_from_string(source)
            return if source.blank?

            source.to_s.match(/\/samples\/.*\.[a-zA-Z0-9]+/) do |match|
              filepath  = File.join(self.root_dir, match.to_s)
              folder    = File.dirname(match.to_s)
              self.items << Locomotive::Mounter::Models::ContentAsset.new(filepath: filepath, folder: folder)
            end
          end

          # Return the directory where all the theme assets
          # are stored in the filesystem.
          #
          # @return [ String ] The theme assets directory
          #
          def root_dir
            File.join(self.runner.path, 'public')
          end

        end

      end

    end
  end
end
