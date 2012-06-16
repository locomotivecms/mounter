module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class PagesBuilder < Base

         attr_accessor :list, :pages_from_config

         def initialize(runner)
           self.list, self.pages_from_config = [], {}
           super
         end

         # Build the tree of pages based on the data specified by the config/site.yml file
         # of the template but also with the filesystem structure
         #
         # @return [ Array ] List of pages. The index page is the first element and the 404 one is the last element.
         #
         def build
           (self.config['site']['pages'] || []).each do |_page|
             self.pages_from_config[_page.keys.first] = _page.values.first
           end

           puts self.pages_from_config.inspect

           self.fetch_element 'index'

           self.list
         end

         def fetch_element(fullpath, parent = nil)
           # does the page exist in the site.yml file
           attributes = self.pages_from_config.delete(fullpath)

           # look for a template in the filesystem
           template_filepath = self.fetch_template_filepath(fullpath)

           if attributes || template_filepath
             # the page does exist
             page = self.build(fullpath, parent, attributes)

             self.list << page

             self.fetch_children(page)
           end
         end

         def fetch_children(page)
           pages = {}

           # from config
           self.pages_from_config.to_a.each_with_index do |attributes, position|
             if self.is_subpage_of?(attributes.first, page.fullpath)
               pages[attributes.first] = attributes.last.merge({
                 fullpath: attributes.first,
                 position: position
               })
             end
           end

           # from filesystem
           # File.dir(File.dirname(fullpath))
         end

         protected

         def is_subpage_of?(fullpath, parent_fullpath)
           return false if %w(index 404).include?(fullpath)

           if parent_fullpath == 'index' && fullpath.split('/') == 0
             return true
           end

           File.dirname(fullpath.dasherize) == parent_fullpath.dasherize
         end

         # Build a new page object. It also looks for other localized
         # version of the template in the filesystem.
         #
         # @param [ String ] fullpath The full path of the page
         # @param [ Object ] parent The page parent (nil for the index page)
         #
         # @return [ Object ] The new page instance
         #
         def build_page(fullpath, parent, attributes)
           (attributes ||= {}).merge! parent: parent, fullpath: fullpath

           Locomotive::Mounter::Models::Page.new(attributes) do |page|
             self.mounting_point.locales.each do |locale|
               next if locale == self.mounting_point.default_locale

               if template_filepath = self.fetch_template_filepath(fullpath, locale)
                 I18n.with_locale(locale) do
                   page.template_filepath = template_filepath
                 end
               end
             end
           end
         end

         # Check if there is a template on the filesystem corresponding to the fullpath.
         # 2 different names are checked: one with the simple .liquid extension,
         # the other one with the .liquid.haml extensions.
         # If no files are found, it returns nil.
         #
         # Note: during the search, if there are dashes in the fullpath given in parameter,
         # they will be replaced by underscores in the filepath
         #
         # @param [ String ] fullpath The fullpath of the page
         #
         # @return [ String ] The complete file path to the template. Nil if not found
         #
         def fetch_template_filepath(fullpath, locale = nil)
           path = File.join(self.runner.path, 'app', 'views', 'pages', fullpath.underscore)

           ['liquid', 'liquid.haml'].each do |extension|
             filepath = locale ? "#{path}.#{locale}" : path

             filepath += "#{filepath}.#{extension}"

             puts "Testing filepath = #{filepath.inspect}"

             return filepath if File.exists?(filepath)
           end

           nil
         end

       end

      end
    end
  end
end