module Locomotive
  module Mounter
    module Writer
      module Api

        # Push theme assets to a remote LocomotiveCMS engine.
        #
        # New assets are automatically pushed.
        # Existing ones are not pushed unless the :force option is
        # passed OR if the size of the asset (if not a javascript or stylesheet) has changed.
        #
        class ThemeAssetsWriter < Base

          # Other local attributes
          attr_accessor :tmp_folder

          def prepare
            super

            # prepare the place where the assets will be stored temporarily.
            self.create_tmp_folder

            # get all the _id
            self.get(:theme_assets, nil, true).each do |attributes|
              remote_path = File.join('/', attributes['folder'], File.basename(attributes['local_path']))

              if theme_asset = self.theme_assets[remote_path]
                theme_asset._id   = attributes['_id']
                theme_asset.size  = attributes['raw_size'].to_i
              end
            end
          end

          def write
            self.theme_assets_by_priority.each do |theme_asset|
              # track it in the logs
              self.output_resource_op theme_asset

              status  = :skipped
              file    = self.build_temp_file(theme_asset)
              params  = theme_asset.to_params.merge(source: file)

              if theme_asset.persisted?
                # we only update it if the size has changed or if the force option has been set.
                if self.force? || (!theme_asset.stylesheet_or_javascript? && File.size(file) != theme_asset.size)
                  response = self.put :theme_assets, theme_asset._id, params

                  status = self.response_to_status(response)
                end
              else
                response = self.post :theme_assets, params, nil, true

                status = self.response_to_status(response)
              end

              # very important. we do not want a huge number of non-closed file descriptor.
              file.close

              # track the status
              self.output_resource_op_status theme_asset, status
            end

            # make the stuff like they were before
            self.remove_tmp_folder
          end

          protected

          # Create the folder to store temporarily the files.
          #
          def create_tmp_folder
            self.tmp_folder = self.runner.parameters[:tmp_dir] || File.join(Dir.getwd, '.push-tmp')

            FileUtils.mkdir_p(self.tmp_folder)
          end

          # Clean the folder which had stored temporarily the files.
          #
          def remove_tmp_folder
            FileUtils.rm_rf(self.tmp_folder) if self.tmp_folder
          end

          # Build a temp file from a theme asset.
          #
          # @param [ Object ] theme_asset The theme asset
          #
          # @return [ File ] The file descriptor
          #
          def build_temp_file(theme_asset)
            path = File.join(self.tmp_folder, theme_asset.path)

            FileUtils.mkdir_p(File.dirname(path))

            File.open(path, 'w') do |file|
              file.write(theme_asset.content)
            end

            File.new(path)
          end

          # Shortcut to get all the local snippets.
          #
          # @return [ Hash ] The hash whose key is the slug and the value is the snippet itself
          #
          def theme_assets
            return @theme_assets if @theme_assets

            @theme_assets = {}.tap do |hash|
              self.mounting_point.theme_assets.each do |theme_asset|
                hash[theme_asset.path] = theme_asset
              end
            end
          end

          # List of theme assets sorted by their priority.
          #
          # @return [ Array ] Sorted list of the theme assets
          #
          def theme_assets_by_priority
            self.theme_assets.values.sort { |a, b| a.priority <=> b.priority }
          end

        end
      end
    end
  end
end