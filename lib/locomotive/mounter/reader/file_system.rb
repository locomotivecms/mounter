module Locomotive
  module Mounter
    module Reader
     module FileSystem

       # Build a singleton instance of the Runner class.
       #
       # @return [ Object ] A singleton instance of the Runner class
       #
       def self.instance
         @@instance ||= Runner.new(:file_system)
       end

       class Runner < Locomotive::Mounter::Reader::Runner

         attr_accessor :path

         # Compass is required
         def prepare
           self.path = parameters.delete(:path)

           if self.path.blank? || !File.exists?(self.path)
             raise Locomotive::Mounter::ReaderException.new('path is required and must exist')
           end

           Locomotive::Mounter::Extensions::Compass.configure(self.path)
         end

         # Ordered list of atomic readers
         #
         # @return [ Array ] List of classes
         #
         def readers
           [SiteReader, ContentTypesReader, PagesReader, SnippetsReader, ContentEntriesReader, ContentAssetsReader, ThemeAssetsReader, TranslationsReader]
         end

       end

      end
    end
  end
end