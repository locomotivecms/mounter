module Locomotive
  module Mounter
    module Writer
      module Api

        class SiteWriter < Base

          # It creates the config folder
          def prepare
            # self.create_folder 'config'
            puts self.get('my_account', nil, true).inspect

            raise 'STOP'
          end

          # It fills the config/site.yml file
          def write
            # self.open_file('config/site.yml') do |file|
            #   file.write(self.mounting_point.site.to_yaml)
            # end
          end

        end

      end
    end
  end
end