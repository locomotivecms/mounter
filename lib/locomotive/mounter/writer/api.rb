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

        class Runner < Locomotive::Mounter::Writer::Runner

          attr_accessor :uri

          # Call the LocomotiveCMS engine to get a token for
          # the next API calls
          def prepare
            self.uri  = self.parameters.delete(:uri)
            email     = self.parameters.delete(:email)
            password  = self.parameters.delete(:password)

            if uri.blank? || email.blank? || password.blank?
              raise Locomotive::Mounter::WriterException.new("one or many API credentials (uri, email, password) are missing")
            end

            begin
              Locomotive::Mounter::EngineApi.set_token(uri, email, password)
            rescue Exception => e
              raise Locomotive::Mounter::WriterException.new("unable to get an API token: #{e.message}")
            end
          end

          # Ordered list of atomic writers
          #
          # @return [ Array ] List of classes
          #
          def writers
            # [SiteWriter, PagesWriter]
            [SiteWriter, SnippetsWriter, ContentTypesWriter, ContentEntriesWriter, PagesWriter, ThemeAssetsWriter]
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