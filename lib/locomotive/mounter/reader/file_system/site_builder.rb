module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class SiteBuilder < Base

         def build
           site = self.config['site'].dup

           site.delete('pages') # we do not need pages at this step

           Locomotive::Mounter::Models::Site.new(site)
         end

        end

      end
    end
  end
end
