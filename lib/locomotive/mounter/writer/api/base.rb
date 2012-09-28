module Locomotive
  module Mounter
    module Writer
      module Api

        class Base

          attr_accessor :mounting_point, :runner

          def initialize(mounting_point, runner)
            self.mounting_point = mounting_point
            self.runner         = runner
          end

          def mounting_point
            self.runner.mounting_point
          end

          def locales
            self.mounting_point.locales
          end

          def site
            self.mounting_point.site
          end

          def get(resource_name, locale = nil, raw = false)
            params = { query: {} }

            params[:query][:locale] = locale if locale

            response = Locomotive::Mounter::EngineApi.get("/#{resource_name}.json", params)

            if response.success?
              data = response.parsed_response

              return data if raw

              self.raw_data_to_object(data)
            else
              nil
            end
          end

          def post(resource_name, params, locale = nil)
            body = { body: { resource_name.to_s.singularize => params } }

            body[:body][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.post("/#{resource_name}.json", body)
            data      = response.parsed_response

            if response.success?
              self.raw_data_to_object(data)
            else
              # puts response.inspect
              data.each do |attribute, errors|
                puts "\t\t #{attribute} => #{[*errors].join(', ')}"
              end if data.respond_to?(:keys)
              nil
            end
          end

          def put(resource_name, id, params, locale = nil)
            body = { body: { resource_name.to_s.singularize => params } }

            body[:body][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.put("/#{resource_name}/#{id}.json", body)
            data      = response.parsed_response

            if response.success?
              self.raw_data_to_object(data)
            else
              # puts response.inspect
              data.each do |attribute, errors|
                puts "\t\t #{attribute} => #{[*errors].join(', ')}"
              end if data.respond_to?(:keys)
              nil
            end
          end

          def safe_attributes
            %w(_id)
          end

          protected

          def raw_data_to_object(data)
            case data
            when Hash then data.to_hash.delete_if { |k, _| !self.safe_attributes.include?(k) }
            when Array
              data.map do |row|
                # puts "#{row.inspect}\n---" # DEBUG
                row.delete_if { |k, _| !self.safe_attributes.include?(k) }
              end
            else
              data
            end
          end

        end

      end
    end
  end
end