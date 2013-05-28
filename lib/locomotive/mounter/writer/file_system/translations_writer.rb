module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class TranslationsWriter < Base

          def prepare
            self.create_folder 'config'
          end

          def write
            content = self.mounting_point.translations.each_with_object({}) do |(key,translation), hash|
              hash[key] = translation.values
            end

            content = content.empty? ? '' : content.to_yaml

            self.open_file('config/translations.yml') do |file|
              file.write content
            end
          end
        end

      end
    end
  end
end