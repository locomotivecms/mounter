module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class SiteBuilder < Base

         def build
           config_path = File.join(self.runner.path, 'config', 'site.yml')

           site = YAML::load(File.open(config_path).read)

           Locomotive::Mounter::Models::Site.new(site).tap do |site|
             Locomotive::Mounter.locale = (site.locales.first || Locomotive::Mounter.locale).to_sym
           end
         end

        end

      end
    end
  end
end
