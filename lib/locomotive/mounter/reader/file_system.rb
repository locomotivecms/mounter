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

         attr_accessor :path, :config, :mounting_point

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

           self.fetch_site_config

           self.build_mounting_point
         end

         protected

         def build_mounting_point
           Locomotive::Mounter::MountingPoint.new.tap do |mounting_point|
             self.mounting_point = mounting_point

             self.fetch_site

             self.fetch_pages
           end
         end

         def fetch_site
           self.mounting_point.site = SiteBuilder.new(self).build.tap do |site|
             site.mounting_point = self.mounting_point
           end
         end

         def fetch_pages
           self.mounting_point.pages = PagesBuilder.new(self).build.tap do |pages|
             pages.each { |page| page.mounting_point = self.mounting_point }
           end
         end

         def fetch_site_config
           config_path = File.join(self.path, 'config', 'site.yml')

           self.config = YAML::load(File.open(config_path).read) #.tap { |c| puts c.inspect }
         end

       end

      end
    end
  end
end