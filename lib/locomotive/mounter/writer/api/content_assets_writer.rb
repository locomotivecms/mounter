module Locomotive
  module Mounter
    module Writer
      module Api

        # Push content assets to a remote LocomotiveCMS engine.
        #
        # The assets come from content blocks, for instance, in a
        # the template of a page or the text fields of content entries.
        # If an asset with the same filename already exists in the engine,
        # the local version will not pushed unless the :force_assets option is passed
        #
        class ContentAssetsWriter < Base

          attr_accessor :remote_assets

          def prepare
            self.remote_assets = {}

            # assign an _id to a local content type if possible
            self.get(:content_assets, nil, true).each do |attributes|
              puts attributes.inspect

              self.remote_assets[attributes['full_filename']] = attributes
            end
          end

          def write(local_path)
            status    = :skipped
            asset     = self.build_asset(local_path)
            response  = self.remote_assets[asset.filename]

            asset._id = response['_id'] if response

            self.output_resource_op asset

            if !asset.exists?
              status = :error
            elsif asset.persisted?
              if asset.size != response['size'].to_i && self.force_assets?
                # update it
                response = self.put :content_assets, asset._id, asset.to_params
                status = self.response_to_status(response)
              end
            else
              # create it
              response = self.post :content_assets, asset.to_params, nil, true
              status = self.response_to_status(response)

              self.remote_assets[response['full_filename']] = response
            end

            self.output_resource_op_status asset, status

            [:success, :skipped].include?(status) ? response['url'] : nil
          end

          protected

          def build_asset(local_path)
            Locomotive::Mounter::Models::ContentAsset.new(filepath: self.absolute_path(local_path))
          end

          def force_assets?
            self.runner.parameters[:force_assets] || false
          end

          def resource_message(resource)
            "  #{super}"
          end

        end
      end
    end
  end
end