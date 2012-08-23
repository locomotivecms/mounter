module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class SiteWriter < Base

          # It creates the config folder
          def prepare
            self.create_folder 'config'
          end

          # It fills the config/site.yml file
          def write
            self.open_file('config/site.yml') do |file|
              file.write(self.mounting_point.site.to_yaml)
            end
          end

        end

      end
    end
  end
end