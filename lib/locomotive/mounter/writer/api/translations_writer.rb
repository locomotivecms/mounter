module Locomotive
  module Mounter
    module Writer
      module Api

        # Push translations to a remote LocomotiveCMS engine.
        #
        # Only pushes if force_translations flag is set
        #
        class TranslationsWriter < Base

          def prepare
            return unless force_translations?
            super

            # set the unique identifier to each local translation
            (self.get(:translations, nil, true) || []).each do |attributes|
              translation = self.translations[attributes['key']]

              translation._id = attributes['id'] if translation
            end
          end

          # Write all the translations to the remote destination
          def write
            return unless force_translations?
            self.translations.each do |key, translation|
              self.output_resource_op translation

              success = translation.persisted? ? self.update_translation(translation) : self.create_translation(translation)

              self.output_resource_op_status translation, success ? :success : :error
              self.flush_log_buffer
            end
          end

          protected

          def force_translations?
            self.runner.parameters[:force_translations] || false
          end
          # Persist a translation by calling the API. The returned id
          # is then set to the translation itself.
          #
          # @param [ Object ] translation The translation to create
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def create_translation(translation)
            params = self.buffer_log { translation.to_params }

            # make a call to the API to create the translation, no need to set
            # the locale since it first happens for the default locale.
            response = self.post :translations, params, nil, true

            translation._id = response['id'] if response

            !response.nil?
          end

          # Update a translation by calling the API.
          #
          # @param [ Object ] translation The translation to persist
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def update_translation(translation)
            params = self.buffer_log { translation.to_params }

            # make a call to the API for the update
            response = self.put :translations, translation._id, params

            !response.nil?
          end

          # Shortcut to get all the local translations.
          #
          # @return [ Hash ] The hash whose key is the tr key and the value is translation itself
          #
          def translations
            self.mounting_point.translations
          end

        end
      end
    end
  end
end