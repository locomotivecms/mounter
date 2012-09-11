module Locomotive
  module Mounter
    module Models

      class EditableElement < Base

        ## fields ##
        field :content, localized: true

        ## other accessors
        attr_accessor :block, :slug

      end

    end
  end
end