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
        field :is_layout,         default: false
        field :allow_layout,      default: false
        field :redirect_url,      localized: true
        field :redirect_type,     default: 301
        field :template,          localized: true
        field :handle
        field :listed,            default: false
        field :searchable
        field :extendable,        default: false
        field :templatized,       default: false
        field :content_type
        field :published,         default: true
        field :cache_strategy
        field :response_type
        field :position

        field :seo_title,         localized: true
        field :meta_keywords,     localized: true
        field :meta_description,  localized: true

        field :editable_elements, type: :array, class_name: 'Locomotive::Mounter::Models::EditableElement'

        ## other accessors ##
        attr_accessor :content_type_id, :content_entry, :parent_id, :children, :templatized_from_parent

        ## path to the file of the template (if mounted from a FS) ##
        attr_accessor :filepath

        ## aliases ##
        alias :listed?      :listed
        alias :published?   :published
        alias :templatized? :templatized
        alias :searchable?  :searchable
        alias :is_layout?   :is_layout

        ## methods ##

        # Tell if the page is either the index page.
        #
        # @return [ Boolean ] True if index page.
        #
        def index?
          self.depth == 0 && 'index' == self.slug
        end

        # Tell if the page is either the index or the 404 page.
        #
        # @return [ Boolean ] True if index or 404 page.
        #
        def index_or_404?
          self.depth == 0 && %w(index 404).include?(self.slug)
        end

        # Return the fullpath dasherized and with the "*" character
        # for the slug of templatized page.
        #
        # @param [ Boolean ] wildcard If true, replace the slug of a templatized page by the "*" character (default: true)
        #
        # @return [ String ] The safe full path or nil if the page is not translated in the current locale
        #
        def safe_fullpath(wildcard = true)
          if self.index_or_404?
            self.slug
          else
            base  = self.parent.safe_fullpath(wildcard)
            _slug = if self.templatized? && !self.templatized_from_parent
              wildcard ? '*' : self.slug
            elsif !self.translated_in?(Locomotive::Mounter.locale)
              self.slug_translations[self.mounting_point.default_locale]
            else
              self.slug
            end
            (base == 'index' ? _slug : File.join(base, _slug)).dasherize
          end
        end

        # Return the fullpath in the current locale. If it does not exist,
        # return the one of the main locale.
        #
        # @return [ String ] A non-blank fullpath
        #
        def fullpath_or_default
          self.fullpath || self.fullpath_in_default_locale
        end

        # Return the fullpath in the default locale no matter the current locale is.
        #
        # @return [ String ] The fullpath
        #
        def fullpath_in_default_locale
          self.fullpath_translations[self.mounting_point.default_locale]
        end

        # Get the id of the parent page.
        #
        # @return [ String ] The _id attribute of the parent page
        #
        def parent_id
          @parent_id || self.parent.try(:_id)
        end

        # Force the translations of a page
        #
        # @param [ Array ] locales List of locales (Symbol or String)
        #
        def translated_in=(locales)
          self._locales = locales.map(&:to_sym)
        end

        # Set the content type, attribute required for templatized page.
        # @deprecated. Use content_type= instead.
        #
        # @param [ Object ] content_type The content type
        #
        def model=(content_type)
          Locomotive::Mounter.logger.warn 'The model attribute is deprecated. Use content_type instead.'
          self.content_type = content_type
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
          self.fullpath_or_default.split('/').size
        end

        # Depth and position in the site tree
        #
        # @return [ Integer ] An unique id corresponding to the depth and position
        #
        def depth_and_position
          self.depth * 1000 + (self.position || 199)
        end

        # Tell if the page extends the template of another page.
        # Basically, we check if the template of the page includes
        # the "extends" liquid tag.
        #
        # @return [ Boolean ] True if the template can be a layout.
        #
        def extends_template?
          !self.template_fullpath.nil?
        end

        # Return the fullpath of the page whose template is extended
        # in the current template.
        #
        # @return [ String ] The fullpath of the "extended" page or nil if no extends tag
        #
        def template_fullpath
          return nil if self.source.nil? || self.source.strip.blank?

          self.source =~ /\{%\s*extends\s+\'?([[\w|\-|\_]|\/]+)\'?\s*%\}/
          $1
        end

        # Is it a redirect page ?
        #
        # @return [ Boolean ] True if the redirect_url property is set
        #
        def redirect?
          !self.redirect_url.blank?
        end

        # Add a child to the page. It also sets the parent of the child.
        # If the parent page is a templatized one, give the same properties to the child.
        #
        # @param [ Object ] page The child page
        #
        # @return [ Object ] The child page
        #
        def add_child(page)
          page.parent = self

          if self.templatized?
            page.templatized_from_parent = true

            # copy properties from the parent
            %w(templatized content_type content_type_id).each do |name|
              page.send(:"#{name}=", self.send(name.to_sym))
            end
          end

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
              _splashed   = _attributes.first.split('/')

              block, slug = _splashed[0..-2].join('/'), _splashed.last
              block       = nil if block.blank?

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
          (self.editable_elements || []).detect do |el|
            el.block.to_s == block.to_s && el.slug.to_s == slug.to_s
          end
        end

        # Localize the fullpath based on the parent fullpath in the locales
        # passed in parameter.
        #
        # @param [ Array ] locales The list of locales the fullpath will be translated to. Can be nil (will use the locales returned by translated_in)
        #
        def localize_fullpath(locales = nil)
          locales ||= self.translated_in
          _parent_fullpath  = self.parent.try(:fullpath)
          _fullpath, _slug  = self.fullpath.try(:clone), self.slug.to_s.clone

          locales.each do |locale|
            Locomotive::Mounter.with_locale(locale) do
              if %w(index 404).include?(_slug) && (_fullpath.nil? || _fullpath == _slug)
                self.fullpath = _slug
                self.slug     = _slug
              elsif _parent_fullpath == 'index'
                self.fullpath = self.slug || _slug
              else
                self.fullpath = File.join(parent.fullpath || _parent_fullpath, self.slug || _slug)
              end
            end
          end
        end

        # Assign a default template for each locale which
        # has an empty template. This default template
        # is the one defined in the default locale.
        #
        # @param [ Symbol / String ] default_locale The default locale
        #
        def set_default_template_for_each_locale(default_locale)
          default_template = self.template_translations[default_locale.to_sym]

          return if self.template_blank?(default_template)

          self.translated_in.each do |locale|
            next if locale.to_s == default_locale.to_s

            # current template
            _template = self.template_translations[locale]

            # is it blank ?
            if self.template_blank?(_template)
              self.template_translations[locale] = default_template
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
        # @return [ String ] The liquid template or nil if not template has been provided
        #
        def source
          @source ||= {}

          if @source[Locomotive::Mounter.locale]
            @source[Locomotive::Mounter.locale] # memoization
          elsif self.template
            @source[Locomotive::Mounter.locale] = self.template.source
          else
            nil
          end
        end

        # Return the YAML front matters of the page
        #
        # @return [ String ] The YAML version of the page
        #
        def to_yaml
          fields = %w(title slug redirect_url redirect_type handle published listed allow_layout is_layout searchable cache_strategy response_type position seo_title meta_description meta_keywords)

          _attributes = self.attributes.delete_if do |k, v|
            !fields.include?(k.to_s) || (!v.is_a?(FalseClass) && v.blank?)
          end.deep_stringify_keys

          # useless attributes
          _attributes.delete('redirect_type') if self.redirect_url.blank?

          # templatized page
          _attributes['content_type'] = self.content_type.slug if self.templatized? && !self.templatized_from_parent

          # editable elements
          _attributes['editable_elements'] = {}
          (self.editable_elements || []).each do |editable_element|
            _attributes['editable_elements'].merge!(editable_element.to_yaml)
          end

          _attributes.delete('editable_elements') if _attributes['editable_elements'].empty?

          _attributes.delete('slug') if self.depth == 0

          "#{_attributes.to_yaml}---\n#{self.source}"
        end

        # Return the params used for the API
        #
        # @return [ Hash ] The params
        #
        def to_params
          params = self.filter_attributes %w(title parent_id slug redirect_url redirect_type handle listed is_layout
            allow_layout published searchable cache_strategy
            response_type position templatized seo_title meta_description meta_keywords extendable)

          # slug
          params.delete(:slug) if self.depth == 0

          # redirect_url
          params[:redirect] = true unless self.redirect_url.blank?

          # parent_id
          params[:parent_id] = self.parent_id unless self.parent_id.blank?

          # content_type
          params[:target_klass_slug] = self.content_type.slug if self.templatized && self.content_type

          # editable_elements
          params[:editable_elements] = (self.editable_elements || []).map(&:to_params)

          # raw_template
          params[:raw_template] = self.source rescue nil

          params
        end

        # Return the params used for the API but without all the params.
        # This can be explained by the fact that for instance the update should preserve
        # the content.
        #
        # @return [ Hash ] The safe params
        #
        def to_safe_params
          fields = %w(title slug listed is_layout allow_layout published searchable handle cache_strategy
            redirect_url response_type templatized content_type_id position
            seo_title meta_description meta_keywords extendable)

          params = self.attributes.delete_if do |k, v|
            !fields.include?(k.to_s) || (!v.is_a?(FalseClass) && v.blank?)
          end.deep_symbolize_keys

          # redirect_url
          params[:redirect] = true unless self.redirect_url.blank?

          # raw_template
          params[:raw_template] = self.source rescue nil

          params
        end

        def to_s
          self.fullpath_or_default
        end

        protected

        # Tell if a template is strictly blank (nil or empty).
        # If a template is invalid, it is not considered as a
        # blank one.
        #
        # @param [ PageTemplate ] template The template to test
        #
        # @return [ Boolean ] True if the template is strictly blank
        #
        def template_blank?(template)
          template.nil? || template.raw_source.strip.blank?
        end

      end

    end
  end
end
