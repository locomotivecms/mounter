module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ContentAssetsWriter < Base

          # It creates the content assets folder
          def prepare
            super
            self.create_folder 'public'
          end

          # It writes all the content assets into files
          def write
            self.mounting_point.content_assets.each do |_, asset|
              self.output_resource_op asset

              self.open_file(self.target_asset_path(asset), 'wb') do |file|
                file.write(asset.content)
              end

              self.output_resource_op_status asset
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