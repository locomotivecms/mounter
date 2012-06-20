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

        # Modified setter in order to set correctly the slug
        #
        # @param [ String ] fullpath The fullpath
        #
        def fullpath_with_setting_slug=(fullpath)
          if fullpath && self.slug.nil?
            self.slug = File.basename(fullpath)
          end

          self.fullpath_without_setting_slug = fullpath
        end

        alias_method_chain :fullpath=, :setting_slug

        # Depth of the page in the site tree.
        # Both the index and 404 pages are 0-depth.
        #
        # @return [ Integer ] The depth
        #
        def depth
          return 0 if %w(index 404).include?(self.fullpath)

          puts "depth #{self.title} / #{self.slug}"

          self.fullpath.split('/').size
        end

        # Add a child to the page. It also sets the parent of the child
        #
        # @param [ Object ] page The child page
        #
        def add_child(page)
          page.parent = self

          (self.children ||= []) << page

          self.children.sort! { |a, b| (a.position || 999) <=> (b.position || 999) }

          page
        end

        def prepare_fullpath(locales)
          puts "prepare_fullpath #{self.fullpath.inspect}, #{locales.inspect}"
          if self.fullpath == 'index'
            locales.each do |locale|
              I18n.with_locale(locale) { self.fullpath = 'index' }
            end
          else
            default_slug        = self.slug
            default_parent_path = self.parent.fullpath

            puts "prepare_fullpath #{default_slug.inspect}, #{default_parent_path.inspect}"

            if self.parent.fullpath == 'index'
              locales.each do |locale|
                I18n.with_locale(locale) do
                  self.fullpath = self.slug || default_slug
                end
              end
            else
              locales.each do |locale|
                I18n.with_locale(locale) do
                  self.fullpath = File.join(parent.fullpath || default_parent_path, self.slug || default_slug)
                end
              end
            end
          end
          puts "-================="
        end

      end

    end
  end
end