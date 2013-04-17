module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ThemeAssetsWriter < Base

          # Create the theme assets folders
          #
          def prepare
            self.create_folder 'public'
          end

          # Write all the snippets into files
          #
          def write
            self.theme_assets_by_priority.each do |asset|
              self.open_file(self.target_asset_path(asset), 'wb') do |file|
                content = asset.content

                if asset.stylesheet_or_javascript?
                  self.replace_asset_urls(content)
                end

                file.write(content)
              end
            end
          end

          protected

          # The urls stored on the remote engine follows the format: /sites/<id>/theme/<type>/<file>
          # This method replaces these urls by their local representation. <type>/<file>
          #
          # @param [ String ] content
          #
          def replace_asset_urls(content)
            return if content.blank?
            content.force_encoding('utf-8').gsub!(/[("']([^)"']*)\/sites\/[0-9a-f]{24}\/theme\/(([^;.]+)\/)*([a-zA-Z_\-0-9]+\.[a-z]{2,3})[)"']/) do |path|
              "#{path.first}/#{$2 + $4}#{path.last}"
            end
          end

          # Return the path where will be copied the asset
          #
          # @param [ String ] asset The asset
          #
          # @return [ String ] The relative path of the asset locally
          #
          def target_asset_path(asset)
            File.join('public', asset.folder, asset.filename)
          end

          # List of theme assets sorted by their priority.
          #
          # @return [ Array ] Sorted list of the theme assets
          #
          def theme_assets_by_priority
            self.mounting_point.theme_assets.sort { |a, b| a.priority <=> b.priority }
          end

        end

      end
    end
  end
end