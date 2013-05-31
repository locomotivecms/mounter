module Locomotive
  module Mounter
    module Reader
      module Api

        class Base

          attr_accessor :runner, :items

          delegate :uri, :uri_with_scheme, to: :runner
          delegate :locales, to: :mounting_point

          def initialize(runner)
            self.runner  = runner
            self.items   = {}
          end

          def mounting_point
            self.runner.mounting_point
          end

          def get(resource_name, locale = nil, raw = false)
            params = { query: {} }

            params[:query][:locale] = locale if locale

            response = Locomotive::Mounter::EngineApi.get("/#{resource_name}.json", params).parsed_response

            return response if raw

            case response
            when Hash then response.to_hash.delete_if { |k, _| !self.safe_attributes.include?(k) }
            when Array
              response.map do |row|
                # puts "#{row.inspect}\n---" # DEBUG
                row.delete_if { |k, _| !self.safe_attributes.include?(k) }
              end
            else
              response
            end
          end

          def add_content_asset(url, folder = nil)
            content_assets = self.mounting_point.resources[:content_assets]

            if (url =~ /^https+:\/\//).nil?
              url = URI.join(self.uri_with_scheme, url)
            end

            Locomotive::Mounter::Models::ContentAsset.new(uri: url, folder: folder).tap do |asset|
              content_assets[url.to_s] = asset
            end
          end

        end

      end
    end
  end
end