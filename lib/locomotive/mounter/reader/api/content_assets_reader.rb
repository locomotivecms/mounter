module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentAssetsReader < Base

          # Build the list of content assets from the public folder with eager loading.
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            super

            self.get(:content_assets).each do |attributes|
              url = attributes.delete('url')

              attributes['folder']  = 'samples/assets'
              attributes['uri']     = URI(url =~ /^https?:\/\// ? url : "#{self.base_uri_with_scheme}#{url}")

              self.items[url] = Locomotive::Mounter::Models::ContentAsset.new(attributes)
            end

            self.items
          end

          protected

          def safe_attributes
            %w(_id url created_at updated_at)
          end

        end

      end

    end
  end
end
