module Locomotive
  module Mounter
    module Writer

      module FileSystem

        # Build a singleton instance of the Runner class.
        #
        # @return [ Object ] A singleton instance of the Runner class
        #
        def self.instance
          @@instance ||= Runner.new(:file_system)
        end

        class Runner < Locomotive::Mounter::Writer::Runner

          attr_accessor :target_path

          # Check the existence of the target_path parameter
          #
          def prepare
            self.target_path = parameters[:target_path]

            if self.target_path.blank?
             raise Locomotive::Mounter::WriterException.new('target_path is required')
           end
          end

          # List of all the writers
          #
          # @return [ Array ] List of the writer classes
          #
          def writers
            [SiteWriter, SnippetsWriter, ContentTypesWriter, ContentEntriesWriter, PagesWriter, ThemeAssetsWriter, TranslationsWriter]
            # [SiteWriter, PagesWriter, SnippetsWriter, ContentTypesWriter, ContentEntriesWriter, ContentAssetsWriter, ThemeAssetsWriter, TranslationsWriter]
          end

        end

      end

    end
  end
end