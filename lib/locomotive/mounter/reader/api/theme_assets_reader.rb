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
            super

            self.items = self.get(:theme_assets).map do |attributes|
              url = attributes.delete('url')
              url.gsub!(/^\/\//, "https://")

              attributes['uri'] = URI(url =~ /^https?:\/\// ? url : "#{self.base_uri_with_scheme}#{url}")

              Locomotive::Mounter::Models::ThemeAsset.new(attributes)
            end
          end

          protected

          def safe_attributes
            %w(_id folder url created_at updated_at)
          end

        end

      end

    end
  end
end
