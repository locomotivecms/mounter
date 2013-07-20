module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ContentTypesWriter < Base

          # It creates the content types folder
          def prepare
            super
            self.create_folder 'app/content_types'
          end

          # It writes all the content types into files
          def write
            self.mounting_point.content_types.each do |filename, content_type|
              self.output_resource_op content_type

              self.open_file("app/content_types/#{filename}.yml") do |file|
                file.write(content_type.to_yaml)
              end

              self.output_resource_op_status content_type
            end
          end

        end

      end
    end
  end
end