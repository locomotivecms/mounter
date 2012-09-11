module Locomotive
  module Mounter
    module Reader
      module Api

        # Build a singleton instance of the Runner class.
        #
        # @return [ Object ] A singleton instance of the Runner class
        #
        def self.instance
          # TODO
          @@instance ||= Runner.new(:api)
        end

        class Runner < Locomotive::Mounter::Reader::Runner

          attr_accessor :uri

          # Call the LocomotiveCMS engine to get a token for
          # the next API calls
          def prepare
            self.uri  = self.parameters.delete(:uri)
            email     = self.parameters.delete(:email)
            password  = self.parameters.delete(:password)

            if uri.blank? || email.blank? || password.blank?
              raise Locomotive::Mounter::ReaderException.new("one or many API credentials (uri, email, password) are missing")
            end

            begin
              Locomotive::Mounter::EngineApi.set_token(uri, email, password)
            rescue Exception => e
              raise Locomotive::Mounter::ReaderException.new("unable to get an API token: #{e.message}")
            end
          end

          # Ordered list of atomic readers
          #
          # @return [ Array ] List of classes
          #
          def readers
            [SiteReader, SnippetsReader, ContentTypesReader, ContentEntriesReader, ContentAssetsReader, PagesReader, ThemeAssetsReader]
          end

        end

      end
    end
  end
end