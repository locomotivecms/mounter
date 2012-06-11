module Locomotive
  module Mounter
    module Reader

     class FileSystem

       attr_accessor :path, :config, :mounting_point

       def run!(options = {})
         self.path = options.delete(:path)

         return nil if self.path.blank? || !File.exists?(self.path)

         self.fetch_site_config

         self.build_mounting_point
       end

       def build_mounting_point
         Locomotive::Mounter::MountingPoint.new.tap do |mounting_point|
           self.mounting_point = mounting_point

           self.fetch_site
         end
       end

       def fetch_site
         site = self.config['site'].dup

         site.delete('pages') # we do not need pages at this step

         self.mounting_point.site = Locomotive::Mounter::Models::Site.new(site).tap do |site|
           site.mounting_point = self.mounting_point
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