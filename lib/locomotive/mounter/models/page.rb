module Locomotive
  module Mounter
    module Models

      class Page < Base

        ## fields ##
        field :parent,            association: true
        field :title,             localized: true
        field :slug,              localized: true
        field :fullpath,          localized: true
        field :redirect_url,      localized: true
        field :template_filepath, localized: true
        field :handle
        field :published
        field :cache_strategy
        field :response_type
        field :position

        ## other accessors ##
        attr_accessor :children

        ## methods ##

        # Return the version of the full path ready to
        # be used to look for template files in the file system.
        # Basically, it underscores the fullpath.
        #
        # @return [ String ] The safe full path ("underscored"). Nil if no fullpath
        #
        def safe_fullpath
          self.fullpath.try(:underscore)
        end

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