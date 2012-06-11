module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        def initialize(attributes = {})
          self.write_attributes(attributes)
        end

      end

    end
  end
end
