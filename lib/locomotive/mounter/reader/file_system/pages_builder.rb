module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class PagesBuilder < Base

         def build
           pages = self.config['site']['pages'] || []

           puts pages.inspect

           []
         end

        end

      end
    end
  end
end

# module Locomotive
#   module Mounter
#     module Reader
#      module FileSystem
#
#        class SiteBuilder < Base
#
#          def build
#            pages = self.config['site']['pages'] || []
#
#            puts pages.inspect
#            # Locomotive::Mounter::Models::Site.new(site)
#          end
#
#         end
#
#       end
#     end
#   end
# end
