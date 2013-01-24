module Locomotive
  module Mounter
    module Models

      class Translation < Base

        ## fields ##
        field :key
        field :values
        
        def to_params
          {_id: self._id, key: self.key, values: self.values}
        end
      end
    end
  end
end