# encoding: UTF-8
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
        field :template,          localized: true
        field :handle
        field :listed
        field :templatized
        field :content_type
        field :published
        field :cache_strategy
        field :response_type
        field :position

        field :editable_elements, type: :array, class_name: 'Locomotive::Mounter::Models::EditableElement'

        ## other accessors ##
        attr_accessor :content_type_id, :parent_id, :children

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

        # Force the translations of a page
        #
        # @param [ Array ] locales List of locales (Symbol or String)
        #
        def translated_in=(locales)
          self._locales = locales.map(&:to_sym)
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
          self.fullpath.split('/').size
        end

        # Add a child to the page. It also sets the parent of the child
        #
        # @param [ Object ] page The child page
        #
        # @return [ Object ] The child page
        #
        def add_child(page)
          page.parent = self

          (self.children ||= []) << page

          self.children.sort! { |a, b| (a.position || 999) <=> (b.position || 999) }

          page
        end

        # Build or update the list of editable elements from a hash whose
        # keys are the couple "[block]/[slug]" and the values the content
        # of the editable elements OR an array of attributes
        #
        # @param [ Hash / Array ] attributes The attributes of the editable elements
        #
        def set_editable_elements(attributes)
          return if attributes.blank?

          self.editable_elements ||= []

          attributes.to_a.each do |_attributes|
            if _attributes.is_a?(Array) # attributes is maybe a Hash
              block, slug = _attributes.first.split('/')
              _attributes = { 'block' => block, 'slug' => slug, 'content' => _attributes.last }
            end

            # does an editable element exist with the same couple block/slug ?
            if editable_element = self.find_editable_element(_attributes['block'], _attributes['slug'])
              editable_element.content = _attributes['content']
            else
              self.editable_elements << Locomotive::Mounter::Models::EditableElement.new(_attributes)
            end
          end
        end

        # Find an editable element from its block and slug (the couple is unique)
        #
        # @param [ String ] block The name of the block
        # @param [ String ] slug The slug of the element
        #
        # @return [ Object ] The editable element or nil if not found
        #
        def find_editable_element(block, slug)
          self.editable_elements.detect { |el| el.block.to_s == block.to_s && el.slug.to_s == slug.to_s }
        end

        # Localize the fullpath based on the parent fullpath in the locales
        # passed in parameter.
        #
        # @param [ Array ] locales The list of locales the fullpath will be translated to. Can be nil (will use the locales returned by translated_in)
        #
        def localize_fullpath(locales = nil)
          locales ||= self.translated_in
          _parent_fullpath  = self.parent.try(:fullpath)
          _fullpath, _slug  = self.fullpath, self.slug

          locales.each do |locale|
            Locomotive::Mounter.with_locale(locale) do
              if _fullpath == 'index'
                self.fullpath = 'index'
              elsif _parent_fullpath == 'index'
                self.fullpath = self.slug || _slug
              else
                self.fullpath = File.join(parent.fullpath || _parent_fullpath, self.slug || _slug)
              end
            end
          end
        end

        # Set the source of the page without any pre-rendering. Used by the API reader.
        #
        # @param [ String ] content The HTML raw template
        #
        def raw_template=(content)
          @source ||= {}
          @source[Locomotive::Mounter.locale] = content
        end

        # Return the Liquid template based on the raw_template property
        # of the page. If the template is HAML or SLIM, then a pre-rendering to Liquid is done.
        #
        # @return [ String ] The liquid template
        #
        def source
          @source ||= {}
          @source[Locomotive::Mounter.locale] ||= self.template.need_for_prerendering? ? self.template.render : self.template.data
        end

        def to_yaml
          fields = %w(title slug redirect_url handle published cache_strategy response_type position)

          _attributes = self.attributes.delete_if { |k, v| !fields.include?(k.to_s) || v.blank? }.deep_stringify_keys

          _attributes['editable_elements'] = {}

          (self.editable_elements || []).each do |editable_element|
            _attributes['editable_elements'].merge!(editable_element.to_yaml)
          end

          _attributes.delete('editable_elements') if _attributes['editable_elements'].empty?

          _attributes.delete('slug') if self.depth == 0

          "#{_attributes.to_yaml}---\n#{self.source}"
        end

      end

    end
  end
end