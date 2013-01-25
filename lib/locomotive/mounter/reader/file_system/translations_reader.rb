module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class TranslationsReader < Base

          # Build the list of translations based on the config/translations.yml file
          #
          # @return [ Hash ] Hash whose the key is the translation key
          #
          def read
            config_path = File.join(self.runner.path, 'config', 'translations.yml')

            {}.tap do |translations|
              if File.exists?(config_path)
                self.read_yaml(config_path).each do |translation|
                  key, values = translation

                  entry = Locomotive::Mounter::Models::Translation.new({
                    key:    key,
                    values: values
                  })

                  translations[key] = entry
                end
              end
            end
          end

        end

      end
    end
  end
end
