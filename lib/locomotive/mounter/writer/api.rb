module Locomotive
  module Mounter
    module Writer
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

        class Runner < Locomotive::Mounter::Writer::Runner

          attr_accessor :uri

          # Call the LocomotiveCMS engine to get a token for
          # the next API calls
          def prepare
            # by default, do not push data (content entries and editable elements)
            self.parameters[:data] ||= false

            credentials = self.parameters.select { |k, _| %w(uri email password api_key).include?(k.to_s) }
            ssl_version = self.parameters[:ssl_version] ? self.parameters[:ssl_version].to_sym : :SSLv3
            self.uri    = credentials[:uri]

            begin
              Locomotive::Mounter::EngineApi.ssl_version(ssl_version)
              Locomotive::Mounter::EngineApi.set_token(credentials)
            rescue Exception => e
              raise Locomotive::Mounter::WriterException.new("unable to get an API token: #{e.message}")
            end
          end

          # Ordered list of atomic writers
          #
          # @return [ Array ] List of classes
          #
          def writers
            [SiteWriter, SnippetsWriter, ContentTypesWriter, ContentEntriesWriter, TranslationsWriter, PagesWriter, ThemeAssetsWriter].tap do |_writers|
              # modify the list depending on the parameters
              if self.parameters
                if self.parameters[:data] == false && !(self.parameters[:only].try(:include?, 'content_entries'))
                  _writers.delete(ContentEntriesWriter)
                end

                if self.parameters[:translations] == false && !(self.parameters[:only].try(:include?, 'translations'))
                  _writers.delete(TranslationsWriter)
                end
              end
            end
          end

          # Get the writer to push content assets
          #
          # @return [ Object ] A memoized instance of the content assets writer
          #
          def content_assets_writer
            @content_assets_writer ||= ContentAssetsWriter.new(self.mounting_point, self).tap do |writer|
              writer.prepare
            end
          end

        end

      end
    end
  end
end
