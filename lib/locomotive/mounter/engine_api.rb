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

    end

  end
end