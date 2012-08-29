module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class SiteReader < Base

         def read
           config_path = File.join(self.runner.path, 'config', 'site.yml')

           site = self.read_yaml(config_path)

           # set the default locale first
           Locomotive::Mounter.locale = site['locales'].first.to_sym rescue Locomotive::Mounter.locale

           Locomotive::Mounter::Models::Site.new(site)
         end

        end

      end
    end
  end
end
