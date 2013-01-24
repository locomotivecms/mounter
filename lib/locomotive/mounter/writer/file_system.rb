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

          # # Write the data of a mounting point instance to a target folder
          # #
          # # @param [ Hash ] parameters The parameters. It should contain the mounting_point and target_path keys.
          # #
          # # @return [ String ] The target path
          # #
          # def run!(parameters = {})
          #   self.mounting_point = parameters[:mounting_point]
            

          #   return nil if self.target_path.blank? || self.mounting_point.nil?

          #   self.write_all

          #   self.target_path
          # end

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
            [SiteWriter, PagesWriter, SnippetsWriter, ContentTypesWriter, ContentEntriesWriter, ContentAssetsWriter, ThemeAssetsWriter, TranslationsWriter]
          end

          # # Execute all the writers
          # def write_all
          #   self.writers.each do |klass|
          #     writer = klass.new(self.mounting_point, self.target_path)
          #     writer.prepare
          #     writer.write
          #   end
          # end

        end

      end

    end
  end
end