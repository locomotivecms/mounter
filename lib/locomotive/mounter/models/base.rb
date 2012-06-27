module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        attr_accessor :mounting_point

      end

    end
  end
end
