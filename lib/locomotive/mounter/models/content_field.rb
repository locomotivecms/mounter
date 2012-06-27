module Locomotive
  module Mounter
    module Models

      class ContentField < Base

        ## fields ##
        field :label
        field :name
        field :type,      default: :string
        field :hint
        field :position,  default: 0
        field :required,  default: false
        field :localized, default: false

        ## callbacks ##
        set_callback :initialize, :after, :prepare_attributes

        ## methods ##

        def prepare_attributes
          self.label ||= self.name.try(:humanize)
          self.type = self.type.to_sym
        end

      end

    end
  end
end