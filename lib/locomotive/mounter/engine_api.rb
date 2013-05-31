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

        self.base_uri _credentials.delete(:uri)

        response = post('/tokens.json', body: _credentials) #{ email: email, password: password })

        if response.code < 400
          self.default_params auth_token: response['token']
          response['token']
        else
          raise WrongCredentials.new("#{response['message']} (#{response.code})")
        end
      end

      def self.teardown
        Locomotive::Mounter::EngineApi.default_options[:base_uri] = nil
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