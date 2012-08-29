module Locomotive
  module Mounter

    class EngineApi

      include HTTParty

      # Get a new token from the Engine API and set it for
      # this class. It raises an exception if the operation fails
      #
      # @param [ String ] uri The base uri (ex: locomotivecms.com or nocoffee.fr)
      # @param [ String ] email The email
      # @param [ String ] password The password
      #
      # @return [ String ] The new token
      #
      def self.set_token(uri, email, password)
        self.base_uri uri

        response = post('/tokens.json', body: { email: email, password: password })

        if response.code < 400
          self.default_params auth_token: response['token']
          response['token']
        else
          raise "#{response['message']} / #{response.code}"
        end
      end

    end

  end
end