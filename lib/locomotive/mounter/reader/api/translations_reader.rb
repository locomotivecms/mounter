module Locomotive
  module Mounter
    module Reader
      module Api

        class TranslationsReader < Base

          # Build the list of translations
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            self.items = get(:translations).map do |attributes|
              Locomotive::Mounter::Models::Translation.new(attributes)
            end
          end

          protected
          def safe_attributes
            %w[_id key values created_at updated_at]
          end
        end

      end

    end
  end
end
