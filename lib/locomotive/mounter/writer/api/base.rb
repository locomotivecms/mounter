module Locomotive
  module Mounter
    module Writer
      module Api

        class Base

          include Locomotive::Mounter::Utils::Output

          attr_accessor :mounting_point, :runner

          delegate :default_locale, :locales, :site, :sprockets, to: :mounting_point

          delegate :content_assets_writer, to: :runner

          delegate :force?, to: :runner

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

          # By setting the data option to true, user content (content entries and
          # editable elements from page) can be pushed too.
          # By default, its value is false.
          #
          # @return [ Boolean ] True if the data option has been set to true
          #
          def data?
            self.runner.parameters[:data] || false
          end

          # Get remote resource(s) from the API
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ String ] locale The locale for the request
          # @param [ Boolean ] dont_filter_attributes False if the we want to only keep the attributes defined by the safe_attributes method
          #
          # @return [ Object] The object or a collection of objects.
          #
          def get(resource_name, locale = nil, dont_filter_attributes = false)
            attribute_names = dont_filter_attributes ? nil : self.safe_attributes

            begin
              Locomotive::Mounter::EngineApi.fetch(resource_name, {}, locale, attribute_names)
            rescue ApiReadException => e
              raise WriterException.new(e.message)
            end
          end

          # Create a resource from the API.
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ Hash ] attributes The attributes of the resource
          # @param [ String ] locale The locale for the request
          # @param [ Boolean ] raw True if the result has to be filtered in order to keep only the attributes defined by the safe_attributes method
          #
          # @return [ Object] The response of the API or nil if an error occurs
          #
          def post(resource_name, attributes, locale = nil, dont_filter_attributes = false)
            attribute_names = dont_filter_attributes ? nil : self.safe_attributes

            begin
              Locomotive::Mounter::EngineApi.create(resource_name, attributes, locale, attribute_names)
            rescue ApiWriteException => e
              message = e.message
              message = message.map do |attribute, errors|
                "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              end.join("\n") if message.respond_to?(:keys)

              raise WriterException.new(message)
            end
          end

          # Update a resource from the API.
          #
          # @param [ String ] resource_name The path to the resource (usually, the resource name)
          # @param [ Hash ] attributes The attributes of the resource
          # @param [ Hash ] params The attributes of the resource
          # @param [ String ] locale The locale for the request
          #
          # @return [ Object] The response of the API
          #
          def put(resource_name, id, attributes, locale = nil)
            begin
              Locomotive::Mounter::EngineApi.update(resource_name, id, attributes, locale, self.safe_attributes)
            rescue ApiWriteException => e
              message = e.message
              message = message.map do |attribute, errors|
                "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              end.join("\n") if message.respond_to?(:keys)

              raise WriterException.new(message)

              # self.log "\n"
              # data.each do |attribute, errors|
              #   self.log "      #{attribute} => #{[*errors].join(', ')}\n".colorize(color: :red)
              # end if data.respond_to?(:keys)
              # nil # DEBUG
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

            source.to_s.gsub(/\/samples\/\S*\.[a-zA-Z0-9]+/) do |match|
              url = self.content_assets_writer.write(match)
              url || match
            end
          end

          protected

          def response_to_status(response)
            response ? :success : :error
          end

          def filtered?(*identifiers)
            return false if runner.parameters[:only_resource].blank?

            !identifiers.any? do |identifier|
              runner.parameters[:only_resource].include?(identifier.to_s)
            end
          end

        end

      end
    end
  end
end
