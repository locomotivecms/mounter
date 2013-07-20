module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ContentEntriesWriter < Base

          # It creates the data folder
          def prepare
            super
            self.create_folder 'data'
          end

          # It writes all the content types into files
          def write
            self.mounting_point.content_types.each do |filename, content_type|
              self.output_resource_op content_type

              entries = (content_type.entries || []).map(&:to_hash)

              self.open_file("data/#{filename}.yml") do |file|
                file.write(entries.to_yaml)
              end

              self.output_resource_op_status content_type
            end
          end

        end
      end
    end
  end
end