module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        attr_accessor :_id, :mounting_point

        ## methods ##

        def persisted?
        	!self._id.blank?
        end

      end

    end
  end
end
