module Locomotive
  module Mounter
    module Models

      class Snippet < Base

        ## fields ##
        field :name
        field :slug
        field :template_filepath, localized: true

      end

    end
  end
end