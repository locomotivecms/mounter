module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentAssetsReader < Base

          # Build the list of theme assets from the public folder with eager loading.
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            base_uri = self.runner.uri.split('/').first
            base_uri = "http://#{base_uri}" unless base_uri =~ /^http:\/\//

            self.get(:content_assets).each do |attributes|
              url = attributes.delete('url')

              attributes['folder']  = 'samples/assets'
              attributes['uri']     = URI(url =~ /http:\/\// ? url : "#{base_uri}#{url}")

              self.items[url] = Locomotive::Mounter::Models::ContentAsset.new(attributes)
            end

            self.items
          end

          protected

          def safe_attributes
            %w(_id url)
          end

        end

      end

    end
  end
end
