module Locomotive
  module Mounter
    module Models

      class EditableElement < Base

        ## fields ##
        field :content, localized: true

        ## other accessors
        attr_accessor :block, :slug

        ## methods ##

        def to_params
          { block: self.block, slug: self.slug, content: self.content }
        end

        def to_yaml
          { "#{block}/#{slug}" => content }
        end

      end

    end
  end
end