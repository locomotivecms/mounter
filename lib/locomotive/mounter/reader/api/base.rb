module Locomotive
  module Mounter
    module Reader
      module Api

        class Base

          include Locomotive::Mounter::Utils::Output

          attr_accessor :runner, :items

          delegate :uri, :uri_with_scheme, :base_uri_with_scheme, to: :runner
          delegate :locales, to: :mounting_point

          def initialize(runner)
            self.runner  = runner
            self.items   = {}
          end

          def mounting_point
            self.runner.mounting_point
          end

          def read
            self.output_title(:pulling)
          end

          def get(resource_name, locale = nil, dont_filter_attributes = false)
            attribute_names = dont_filter_attributes ? nil : self.safe_attributes

            begin
              Locomotive::Mounter::EngineApi.fetch(resource_name, {}, locale, attribute_names)
            rescue ApiReadException => e
              raise ReaderException.new(e.message)
            end
          end

          # Build a new content asset from an url and a folder and add it
          # to the global list of the content assets.
          #
          # @param [ String ] url The url of the content asset.
          # @param [ String ] folder The folder of the content asset (optional).
          #
          # @return [ String ] The local path (not absolute) of the content asset.
          #
          def add_content_asset(url, folder = nil)
            content_assets = self.mounting_point.resources[:content_assets]

            if (url =~ /^https?:\/\//).nil?
              url = URI.join(self.uri_with_scheme, url)
            else
              url = URI(url)
            end

            asset = Locomotive::Mounter::Models::ContentAsset.new(uri: url, folder: folder)

            content_assets[url.path] = asset

            asset.local_filepath
          end

        end

      end
    end
  end
end
