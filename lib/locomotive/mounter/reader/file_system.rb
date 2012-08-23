module Locomotive
  module Mounter
    module Reader
     module FileSystem

       # Build a singleton instance of the Runner class.
       #
       # @return [ Object ] A singleton instance of the Runner class
       #
       def self.instance
         @@instance ||= Runner.new
       end

       class Runner

         attr_accessor :path, :mounting_point

         # Read / parse the content of a folder and build
         # all the related data of the site.
         #
         # @param [ Hash ] parameters The parameters. It should contain the path key.
         #
         # @return [ Object ] The mounting point object storing all the information about the site
         #
         def run!(parameters = {})
           self.path = parameters.delete(:path)

           return nil if self.path.blank? || !File.exists?(self.path)

           self.build_mounting_point
         end

         # Ordered list of builders
         #
         # @return [ Array ] List of classes
         #
         def builders
           [SiteBuilder, PagesBuilder, SnippetsBuilder, ContentTypesBuilder, ContentEntriesBuilder]
         end

         protected

         def build_mounting_point
           Locomotive::Mounter::MountingPoint.new.tap do |mounting_point|
             self.mounting_point = mounting_point

             self.builders.each do |builder|
               name = builder.name.gsub(/Builder$/, '').demodulize.underscore

               self.mounting_point.register_resource(name, builder.new(self).build)
             end
           end
         end

       end

      end
    end
  end
end