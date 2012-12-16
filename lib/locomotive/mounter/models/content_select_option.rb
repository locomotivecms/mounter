module Locomotive
  module Mounter
    module Models

      class ContentSelectOption < Base

        ## fields ##
        field :name,      localized: true
        field :position,  default: 0

        ## methods ##

        # Return the params used for the API.
        #
        # @param [ Hash ] options For now, none
        #
        # @return [ Hash ] The params
        #
        def to_params(options = nil)
          { name: self.name_translations, position: self.position }.tap do |params|
            params[:id] = self._id if self.persisted?
          end
        end

      end

    end
  end
end