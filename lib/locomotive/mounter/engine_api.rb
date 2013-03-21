module Locomotive
  module Mounter

    class EngineApi

      include HTTMultiParty

      format :json

      # Get a new token from the Engine API and set it for
      # this class. It raises an exception if the operation fails.
      # Example of the base uri: locomotivecms.com, nocoffee.fr.
      #
      # @param [ Hash / Array ] *args A hash or parameters in that order: uri, email, password
      #
      # @return [ String ] The new token
      #
      def self.set_token(*args)
        uri, email, password = (if args.first.is_a?(Hash)
          [args.first[:uri], args.first[:email], args.first[:password]]
        else
          [*args]
        end)

        self.base_uri uri

        response = post('/tokens.json', body: { email: email, password: password })

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

    end

  end
end