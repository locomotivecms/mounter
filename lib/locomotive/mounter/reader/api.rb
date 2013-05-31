module Locomotive
  module Mounter
    module Reader
      module Api

        # Build a singleton instance of the Runner class.
        #
        # @return [ Object ] A singleton instance of the Runner class
        #
        def self.instance
          @@instance ||= Runner.new(:api)
        end

        def self.teardown
          @@instance = nil
        end

        class Runner < Locomotive::Mounter::Reader::Runner

          attr_accessor :uri

          # Call the LocomotiveCMS engine to get a token for
          # the next API calls
          def prepare
            credentials = self.parameters.select { |k, _| %w(uri email password api_key).include?(k.to_s) }
            self.uri    = credentials[:uri]

            begin
              Locomotive::Mounter::EngineApi.set_token(credentials) #uri, email, password)
            rescue Exception => e
              raise Locomotive::Mounter::ReaderException.new("unable to get an API token: #{e.message}")
            end
          end

          # Ordered list of atomic readers
          #
          # @return [ Array ] List of classes
          #
          def readers
            [SiteReader, ContentAssetsReader, SnippetsReader, ContentTypesReader, ContentEntriesReader, PagesReader, ThemeAssetsReader, TranslationsReader]
          end

        end

      end
    end
  end
end