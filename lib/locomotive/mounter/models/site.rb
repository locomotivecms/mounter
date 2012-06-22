module Locomotive
  module Mounter
    module Models

      class Site < Base

        ## fields ##
        field :name
        field :locales
        field :seo_title,        localized: true
        field :meta_keywords,    localized: true
        field :meta_description, localized: true

      end

    end
  end
end