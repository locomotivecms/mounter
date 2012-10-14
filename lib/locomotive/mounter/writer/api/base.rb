module Locomotive
  module Mounter
    module Writer
      module Api

        class Base

          attr_accessor :mounting_point, :runner

          delegate :default_locale, :locales, :site, to: :mounting_point

          def initialize(mounting_point, runner)
            self.mounting_point = mounting_point
            self.runner         = runner
          end

          # A write may have to do some work before being launched.
          # By default, it displays to the output the resource being pushed.
          #
          def prepare
            self.output_title
          end

          # By setting the force option to true, some resources (Site, Page, Snippet)
          # may overide the content of the remote engine during the push operation.
          #
          def force?
            self.runner.parameters[:force] || false
          end

          # Get remote resource(s) by the API
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ String ] locale The locale for the request
          # @param [ Boolean ] raw True if the result has to be converted into object.
          #
          # @return [ Object] The object or a collection of objects.
          #
          def get(resource_name, locale = nil, raw = false)
            params = { query: {} }

            params[:query][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.get("/#{resource_name}.json", params)
            data      = response.parsed_response

            if response.success?
              return data if raw
              self.raw_data_to_object(data)
            else
              nil
            end
          end

          # Create a resource by the API.
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ Hash ] params The attributes of the resource
          # @param [ String ] locale The locale for the request
          # @param [ Boolean ] raw True if the result has to be converted into object.
          #
          # @return [ Object] The response of the API or nil if an error occurs
          #
          def post(resource_name, params, locale = nil, raw = false)
            body = { body: { resource_name.to_s.singularize => params } }

            body[:body][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.post("/#{resource_name}.json", body)
            data      = response.parsed_response

            if response.success?
              return data if raw
              self.raw_data_to_object(data)
            else
              # puts response.inspect
              self.log "\n"
              data.each do |attribute, errors|
                self.log "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              end if data.respond_to?(:keys)
              nil
            end
          end

          # Update a resource by the API.
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ String ] id The unique identifier of the resource
          # @param [ Hash ] params The attributes of the resource
          # @param [ String ] locale The locale for the request
          #
          # @return [ Object] The response of the API or nil if an error occurs
          #
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
                self.log "\t\t #{attribute} => #{[*errors].join(', ')}".colorize(color: :red)
              end if data.respond_to?(:keys)
              nil
            end
          end

          def safe_attributes
            %w(_id)
          end

          protected

          # Convert raw data into the corresponding object (Page, Site, ...etc)
          #
          # @param [ Hash ] data The attributes of the object
          #
          # @return [ Object ] A new instance of the object
          #
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

          # Print the the title for each kind of resource.
          #
          def output_title
            msg = "* Pushing #{self.class.name.gsub(/Writer$/, '').demodulize}"
            self.log msg.colorize(background: :white, color: :black) + "\n"
          end

          # Print the current locale.
          #
          def output_locale
            locale = Locomotive::Mounter.locale.to_s
            self.log "  #{locale.colorize(background: :blue, color: :white)}\n"
          end

          # Print the message about the creation / update of a resource.
          #
          # @param [ Object ] resource The resource (Site, Page, ...etc).
          #
          def output_resource_op(resource)
            self.log self.resource_message(resource)
          end

          # Print the message about the creation / update of a resource.
          #
          # @param [ Object ] resource The resource (Site, Page, ...etc).
          # @param [ Boolean ] success True if everything went okay
          #
          def output_resource_op_status(resource, success = true)
            status_label  = success ? 'done'.colorize(color: :green) : 'error'.colorize(color: :red)
            spaces        = ' ' * (80 - self.resource_message(resource).size)
            self.log "#{spaces}[#{status_label}]\n"
          end

          # Return the message about the creation / update of a resource.
          #
          # @param [ Object ] resource The resource (Site, Page, ...etc).
          #
          # @return [ String ] The message
          #
          def resource_message(resource)
            op_label = resource.persisted? ? 'updating': 'creating'
            "    #{op_label} #{resource.to_s}"
          end

          # Log a message to the console or the logger depending on the options
          # of the runner. Info is the log level if case the logger has been chosen.
          #
          # @param [ String ] message The message to log.
          #
          def log(message)
            if self.runner.parameters[:console]
              print message
            else
              Mounter.logger.info message.gsub(/\n$/, '')
            end
          end

        end

      end
    end
  end
end