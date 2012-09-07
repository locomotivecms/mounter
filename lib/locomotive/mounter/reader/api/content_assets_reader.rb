module Locomotive
  module Mounter
    module Reader
      module Api

        class ContentAssetsReader < Base

          # def initialize(runner)
          #   super
          #   self.items = []
          # end

          # Build the list of theme assets from the public folder with eager loading.
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            puts self.get(:content_assets, nil, false).inspect

            raise 'STOP'


            base_uri = self.runner.uri.split('/').first
            base_uri = "http://#{base_uri}" unless base_uri =~ /^http:\/\//

            self.get(:content_assets).map do |attributes|
              puts attributes.inspect



              attributes['uri'] = URI("#{base_uri}#{attributes.delete('url')}")



              # selfLocomotive::Mounter::Models::ThemeAsset.new(attributes)
            end
          end

          protected

          def safe_attributes
            %w(_id folder url)
          end

        end

      end

    end
  end
end
