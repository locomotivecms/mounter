module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ThemeAssetsWriter < Base

          # It creates the theme assets folders
          def prepare
            self.create_folder 'public'
          end

          # It writes all the snippets into files
          def write
            self.mounting_point.theme_assets.each do |asset|
              self.open_file(self.target_asset_path(asset)) do |file|
                file.write(asset.content)
              end
            end
          end

          protected

          def target_asset_path(asset)
            File.join('public', asset.folder, asset.filename)
          end

        end

      end
    end
  end
end