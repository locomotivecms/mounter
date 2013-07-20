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
              Locomotive::Mounter::EngineApi.set_token(credentials)
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

          # Return the uri with the scheme (http:// or https://)
          #
          # @return [ String ] The uri starting by http:// or https://
          #
          def uri_with_scheme
            self.uri =~ /^http/ ? self.uri : "http://#{self.uri}"
          end

          # Return the base uri with the scheme ((http:// or https://)) and without the path (/locomotive/...)
          #
          # @return [ String ] The uri starting by http:// or https:// and without the path
          #
          def base_uri_with_scheme
            self.uri_with_scheme.to_s[/^https?:\/\/[^\/]+/] || self.uri_with_scheme
          end

        end

      end
    end
  end
end