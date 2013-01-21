module Locomotive
  module Mounter
    module Writer
      module Api

        class Base

          @@buffer_enabled  = false
          @@buffer_log      = ''

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

          # By setting the force option to true, some resources (site, content assets, ...etc)
          # may overide the content of the remote engine during the push operation.
          # By default, its value is false.
          #
          # @return [ Boolean ] True if the force option has been set to true
          #
          def force?
            self.runner.parameters[:force] || false
          end

          # By setting the data option to true, user content (content entries and
          # editable elements from page) can be pushed too.
          # By default, its value is false.
          #
          # @return [ Boolean ] True if the data option has been set to true
          #
          def data?
            self.runner.parameters[:data] || false
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
            params_name = resource_name.to_s.split('/').last.singularize

            query = { query: { params_name => params } }

            query[:query][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.post("/#{resource_name}.json", query)
            data      = response.parsed_response

            if response.success?
              return data if raw
              self.raw_data_to_object(data)
            else
              message = data

              message = data.map do |attribute, errors|
                "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              end.join("\n") if data.respond_to?(:keys)

              raise WriterException.new(message)

              # self.log "\n"
              # data.each do |attribute, errors|
              #   self.log "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              # end if data.respond_to?(:keys)
              # nil
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
            params_name = resource_name.to_s.split('/').last.singularize

            query = { query: { params_name => params } }

            query[:query][:locale] = locale if locale

            response  = Locomotive::Mounter::EngineApi.put("/#{resource_name}/#{id}.json", query)
            data      = response.parsed_response

            if response.success?
              self.raw_data_to_object(data)
            else
              message = data

              message = data.map do |attribute, errors|
                "      #{attribute} => #{[*errors].join(', ')}" #.colorize(color: :red)
              end.join("\n") if data.respond_to?(:keys)

              raise WriterException.new(message)

              # data.each do |attribute, errors|
              #   self.log "\t\t #{attribute} => #{[*errors].join(', ')}".colorize(color: :red)
              # end if data.respond_to?(:keys)
              # nil
            end
          end

          def safe_attributes
            %w(_id)
          end

          # Loop on each locale of the mounting point and
          # change the current locale at the same time.
          def each_locale(&block)
            self.mounting_point.locales.each do |locale|
              Locomotive::Mounter.with_locale(locale) do
                block.call(locale)
              end
            end
          end

          # Return the absolute path from a relative path
          # pointing to an asset within the public folder
          #
          # @param [ String ] path The path to the file within the public folder
          #
          # @return [ String ] The absolute path
          #
          def absolute_path(path)
            File.join(self.mounting_point.path, 'public', path)
          end

          # Take a path and convert it to a File object if possible
          #
          # @param [ String ] path The path to the file within the public folder
          #
          # @return [ Object ] The file
          #
          def path_to_file(path)
            File.new(self.absolute_path(path))
          end

          # Take in the source the assets whose url begins by "/samples",
          # upload them to the engine and replace them by their remote url.
          #
          # @param [ String ] source The source text
          #
          # @return [ String ] The source with remote urls
          #
          def replace_content_assets!(source)
            return source if source.blank?

            source.gsub(/\/samples\/.*\.[a-zA-Z0-9]+/) do |match|
              url = self.runner.content_assets_writer.write(match)
              url || match
            end
          end

          protected

          def response_to_status(response)
            response ? :success : :error
          end

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
          # @param [ Symbol ] status :success, :error, :skipped
          # @param [ String ] errors The error messages
          #
          def output_resource_op_status(resource, status = :success, errors = nil)
            status_label = case status
            when :success         then 'done'.colorize(color: :green)
            when :error           then 'error'.colorize(color: :red)
            when :skipped         then 'skipped'.colorize(color: :magenta)
            when :not_translated  then 'not translated (itself or parent)'.colorize(color: :yellow)
            end

            spaces = '.' * (80 - self.resource_message(resource).size)
            self.log "#{spaces}[#{status_label}]\n"

            if errors && status == :error
              self.log "#{errors.colorize(color: :red)}\n"
            end
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
            # puts "buffer ? #{@@buffer_enabled.inspect}"
            if @@buffer_enabled
              @@buffer_log << message
            else
              if self.runner.parameters[:console]
                print message
              else
                Mounter.logger.info message #.gsub(/\n$/, '')
              end
            end
          end

          # Put in a buffer the logs generated when executing the block.
          # It means that they will not output unless the flush_log_buffer
          # method is called.
          #
          # @return [ Object ] Thee value returned by the call of the block
          #
          def buffer_log(&block)
            @@buffer_log = ''
            @@buffer_enabled = true
            if block_given?
              block.call.tap { @@buffer_enabled = false }
            end
          end

          # Flush the logs put in a buffer.
          #
          def flush_log_buffer
            @@buffer_enabled = false
            self.log(@@buffer_log)
            @@buffer_log = ''
          end

        end

      end
    end
  end
end