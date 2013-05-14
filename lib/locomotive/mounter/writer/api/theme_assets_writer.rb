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

          # store checksums of remote assets. needed to check if an asset has to be updated or not
          attr_accessor :checksums

          # the assets stored in the engine have the same base url
          attr_accessor :remote_base_url

          def prepare
            super

            self.checksums = {}

            # prepare the place where the assets will be stored temporarily.
            self.create_tmp_folder

            # assign an _id to a local content type if possible
            self.get(:theme_assets, nil, true).each do |attributes|
              remote_path = File.join('/', attributes['folder'], File.basename(attributes['local_path']))

              if theme_asset = self.theme_assets[remote_path]
                theme_asset._id                 = attributes['id']
                self.checksums[theme_asset._id] = attributes['checksum']
              end

              if remote_base_url.nil?
                attributes['url'] =~ /(.*\/sites\/[0-9a-f]+\/theme)/
                self.remote_base_url = $1
              end
            end
          end

          def write
            self.theme_assets_by_priority.each do |theme_asset|
              # track it in the logs
              self.output_resource_op theme_asset

              status  = :skipped
              errors  = []
              file    = self.build_temp_file(theme_asset)
              params  = theme_asset.to_params.merge(source: file, performing_plain_text: false)

              begin
                if theme_asset.persisted?
                  # we only update it if the size has changed or if the force option has been set.
                  if self.force? || self.theme_asset_changed?(theme_asset)
                    response  = self.put :theme_assets, theme_asset._id, params
                    status    = self.response_to_status(response)
                  else
                    status = :same
                  end
                else
                  response  = self.post :theme_assets, params, nil, true
                  status    = self.response_to_status(response)
                end
              rescue Exception => e
                if self.force?
                  status, errors = :error, e.message
                else
                  raise e
                end
              end

              # very important. we do not want a huge number of non-closed file descriptor.
              file.close

              # track the status
              self.output_resource_op_status theme_asset, status, errors
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

          # Shortcut to get all the theme assets.
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

          # Tell if the theme_asset has been changed in order to update it
          # if so or simply skip it.
          #
          # @param [ Object ] theme_asset The theme asset
          #
          # @return [ Boolean ] True if the checksums of the local and remote files are different.
          #
          def theme_asset_changed?(theme_asset)
            content = theme_asset.content

            if theme_asset.stylesheet_or_javascript?
              # we need to compare compiled contents (sass, coffeescript) with the right urls inside
              content = content.gsub(/[("'](\/(stylesheets|javascripts|images|media|others)\/(([^;.]+)\/)*([a-zA-Z_\-0-9]+)\.[a-z]{2,3})[)"']/) do |path|
                sanitized_path = path.gsub(/[("')]/, '').gsub(/^\//, '')
                sanitized_path = File.join(self.remote_base_url, sanitized_path)

                "#{path.first}#{sanitized_path}#{path.last}"
              end
            end

            # compare local checksum with the remote one
            Digest::MD5.hexdigest(content) != self.checksums[theme_asset._id]
          end

        end
      end
    end
  end
end