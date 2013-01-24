module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class TranslationsWriter < Base

          def prepare
            self.create_folder 'config'
          end

          def write
            self.open_file('config/translations.yml') do |file|
              file.write(self.mounting_point.translations.to_yaml)
            end
          end
        end

      end
    end
  end
end