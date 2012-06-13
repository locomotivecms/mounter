module Locomotive
  module Mounter
    module Models

     class Page < Base

       ## fields ##
       field :parent,             association: true
       field :title,              localized: true
       field :slug,               localized: true
       field :fullpath,           localized: true
       field :template_filepath,  localized: true
       field :handle
       field :published
       field :cache_strategy
       field :response_type

       ## other accessors ##
       attr_accessor :template_filepath, :children

       ## methods ##

       def depth
         return 0 if %w(index 404).include?(self.fullpath)

         self.fullpath.split('/').size + 1
       end

       def add_child(page)
         (self.children ||= []) << page
       end

     end

    end
  end
end