module Locomotive
  module Mounter
    module Writer
      module Api

        class TranslationsWriter < Base

          def write
            self.mounting_point.translations.each do |translation|
              response = self.put :translations, translation._id, translation.to_params
              status = self.response_to_status(response)
              self.output_resource_op_status translation, status
              
            end
          end
        end
      end
    end
  end
end