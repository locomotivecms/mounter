module Locomotive
  module Mounter
    module Reader
      module Api

        class ThemeAssetsReader < Base

          def initialize(runner)
            super
            self.items = []
          end

          # Build the list of theme assets from the public folder with eager loading.
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            # puts self.get(:theme_assets, nil, true).inspect

            base_uri = self.runner.uri.split('/').first
            base_uri = "http://#{base_uri}" unless base_uri =~ /^http:\/\//

            self.items = self.get(:theme_assets).map do |attributes|
              # attributes['url'] =

              # uri = URI("#{base_uri}#{attributes['url']}").tap { |s| puts s.to_s }
              attributes['uri'] = URI("#{base_uri}#{attributes.delete('url')}")

              foo = Locomotive::Mounter::Models::ThemeAsset.new(attributes)

              puts foo.content.inspect
              # puts open(attributes['url']).inspect

              # url = attributes['url']

              # r = ::Net::HTTP.get_reponse(URI.parse(url))
              # puts r.body.inspect

              # puts Net::HTTP.get(uri).inspect # => String

              raise 'STOP'
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
