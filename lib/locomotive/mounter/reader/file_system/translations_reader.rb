module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class TranslationsReader < Base

         def read
           config_path = File.join(self.runner.path, 'config', 'translations.yml')

           self.read_yaml(config_path).map do |translation|
             Locomotive::Mounter::Models::Translation.new(translation)
           end
         end

        end

      end
    end
  end
end
