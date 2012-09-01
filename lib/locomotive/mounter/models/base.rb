module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        attr_accessor :_id, :mounting_point

      end

    end
  end
end
