module Locomotive
  module Mounter
    module Reader

     class FileSystem

       attr_accessor :path, :config, :mounting_point

       def run!(options = {})
         self.path = options.delete(:path)

         return nil unless File.exists?(self.path)

         self.mounting_point = Locomotive::Mounter::MountingPoint.new

         self.fetch_site_config

         self.fetch_site
       end

       def fetch_site
         # puts "Feed site !!!"
         site = self.config['site']

         self.mounting_point.site = Locomotive::Mounter::Models::Site.new(site)

         puts self.mounting_point.site.inspect
       end

       def fetch_site_config
         config_path = File.join(self.path, 'config', 'site.yml')

         self.config = YAML::load(File.open(config_path).read).tap { |c| puts c.inspect }
       end

     end

    end
  end
end