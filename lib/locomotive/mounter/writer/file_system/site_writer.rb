module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class SiteWriter < Base

          # It creates the config folder
          def prepare
            super
            self.create_folder 'config'
          end

          # It fills the config/site.yml file
          def write
            self.open_file('config/site.yml') do |file|
              self.output_resource_op self.mounting_point.site

              file.write(self.mounting_point.site.to_yaml)

              self.output_resource_op_status self.mounting_point.site
            end
          end

        end

      end
    end
  end
end