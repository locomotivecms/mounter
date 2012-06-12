module Locomotive
  module Mounter
    module Models

     class Page < Base

       ## fields ##
       field :parent,         :association => true
       field :title,          :localized => true
       field :slug,           :localized => true
       field :fullpath,       :localized => true
       field :handle
       field :published
       field :cache_strategy
       field :response_type

     end

    end
  end
end