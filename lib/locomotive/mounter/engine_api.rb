require 'uri'

module Locomotive
  module Mounter

    class EngineApi

      include HTTMultiParty

      format :json

      # Get a new token from the Engine API and set it for
      # this class. It raises an exception if the operation fails.
      # Example of the base uri: locomotivecms.com, nocoffee.fr.
      #
      # @param [ Hash / Array ] *args A hash or parameters in that order: uri, email, password or uri, api_key
      #
      # @return [ String ] The new token
      #
      def self.set_token(*args)
        _credentials = self.credentials(args)

        uri = URI _credentials.delete(:uri)
        self.base_uri uri.to_s
        self.basic_auth uri.user, uri.password if uri.userinfo

        response = post('/tokens.json', body: _credentials) #{ email: email, password: password })

        if response.code < 400
          self.default_params auth_token: response['token']
          response['token']
        elsif response.code == 404 # ssl option missing
          raise WrongCredentials.new("#{uri}/tokens.json does not respond. Perhaps, the ssl option is missing in your config/deploy.yml file")
        else
          raise WrongCredentials.new("#{response['message']} (#{response.code})")
        end
      end

      # Read a resource or a list of resources from the API
      # Raise an exception if something went wrong.
      #
      # @param [ String ] resource_name The path to the resource (usually, the resource name)
      # @param [ Hash ] query If we want to filter the results
      # @param [ String ] locale The locale for the request
      # @param [ Array ] attribute_names The attributes we want to keep in the response
      #
      def self.fetch(resource_name, query = {}, locale = nil, attribute_names = nil)
        params = { query: query || {} }
        params[:query][:locale] = locale if locale

        url       = "/#{resource_name}.json"
        response  = self.get(url, params)
        data      = response.parsed_response

        if response.success?
          object_or_list = self.keep_attributes(data, attribute_names)

          if response.headers['x-total-pages']
            PaginatedCollection.new(url, params, attribute_names).tap do |collection|
              collection.list           = object_or_list
              collection.total_pages    = response.headers['x-total-pages'].to_i
              collection.total_entries  = response.headers['x-total-entries'].to_i
            end
          else
            object_or_list
          end
        else
          raise ApiReadException.new(data['error'])
        end
      end

      # Create a resource from the API.
      # Raise an exception if something went wrong.
      #
      # @param [ String ] resource_name The path to the resource (usually, the resource name)
      # @param [ Hash ] attributes The attributes of the resource
      # @param [ String ] locale The locale for the request
      # @param [ Array ] attribute_names The attributes we want to keep in the response
      #
      # @return [ Object] The response of the API
      #
      def self.create(resource_name, attributes, locale = nil, attribute_names = nil)
        params    = self.build_create_or_params(resource_name, attributes, locale)
        response  = self.post("/#{resource_name}.json", params)
        data      = response.parsed_response

        if response.success?
          self.keep_attributes(data, attribute_names)
        else
          raise ApiWriteException.new(data)
        end
      end

      # Update a resource from the API.
      # Raise an exception if something went wrong.
      #
      # @param [ String ] resource_name The path to the resource (usually, the resource name)
      # @param [ String ] id The unique identifier of the resource
      # @param [ Hash ] attributes The attributes of the resource
      # @param [ String ] locale The locale for the request
      # @param [ Array ] attribute_names The attributes we want to keep in the response
      #
      # @return [ Object] The response of the API
      #
      def self.update(resource_name, id, attributes, locale = nil, attribute_names = nil)
        params    = self.build_create_or_params(resource_name, attributes, locale)
        response  = self.put("/#{resource_name}/#{id}.json", params)
        data      = response.parsed_response

        if response.success?
          self.keep_attributes(data, attribute_names)
        else
          raise ApiWriteException.new(data)
        end
      end

      def self.teardown
        Locomotive::Mounter::EngineApi.default_options[:base_uri] = nil
        Locomotive::Mounter::EngineApi.default_options[:base_auth] = nil
        Locomotive::Mounter::EngineApi.default_options[:default_params] = {}
      end

      protected

      def self.credentials(args)
        if args.first.is_a?(Hash)
          args.first
        elsif args.size == 3
          # uri, email, password
          { uri: args[0], email: args[1], password: args[2] }
        elsif args.size == 2
          # uri, api_key
          { uri: args[0], api_key: args[1] }
        else
          {}
        end
      end

      def self.build_create_or_params(resource_name, attributes, locale)
        name = resource_name.to_s.split('/').last.singularize

        params = { query: { name => attributes } }
        params[:query][:locale] = locale if locale

        params
      end

      def self.keep_attributes(data, attribute_names)
        return data if attribute_names.blank?

        case data
        when Hash then data.to_hash.delete_if { |k, _| !attribute_names.include?(k) }
        when Array
          data.map do |row|
            row.delete_if { |k, _| !attribute_names.include?(k) }
          end
        else
          data
        end
      end

    end

    class PaginatedCollection < Struct.new(:url, :params, :attribute_names)

      attr_accessor :list, :total_pages, :total_entries

      alias :size :total_entries

      def each(&block)
        if self.total_pages == 1 && self.list
          self.list.each(&block)
        else
          self.paginated_each(&block)
        end
      end

      def paginated_each(&block)
        loop do
          self.params[:query][:page] = self.page

          response  = Locomotive::Mounter::EngineApi.get(self.url, self.params)
          data      = response.parsed_response

          if response.success?
            self.list = Locomotive::Mounter::EngineApi.send(:keep_attributes, data, self.attribute_names)
            self.list.each(&block)
          else
            raise ApiReadException.new(data['error'])
          end

          break if self.page >= self.total_pages

          @page += 1
        end
      end

      def page
        @page ||= 1
      end

    end

  end
end
