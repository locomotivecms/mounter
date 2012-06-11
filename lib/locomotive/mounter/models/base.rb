module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        def initialize(attributes = {})
          self.write_attributes(attributes)
        end

        def write_attributes(attributes)
          return if attributes.blank?

          attributes.each do |name, value|
            if self.localized?(name) && value.is_a?(Hash)
              self.send(:"#{name}_translations=", value)
            else
              self.send(:"#{name}=", value)
            end
          end
        end

      end

    end
  end
end
