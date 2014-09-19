module Locomotive
  module Mounter
    module Models

      class Translation < Base

        ## fields ##
        field :key
        field :values

        ## methods ##

        def get(locale)
          self.values[locale.to_s]
        end

        def to_params
          { key: self.key, values: self.values }
        end

        def to_s
          "Translation #{self.key} (#{self.values.keys.join(', ')})"
        end

      end
    end
  end
end