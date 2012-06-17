module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class PagesBuilder < Base

         attr_accessor :pages

         def initialize(runner)
           self.pages = {}
           super
         end

         # Build the tree of pages based on the data specified by the config/site.yml file
         # of the template but also with the filesystem structure
         #
         # @return [ Hash ] The pages organized as a Hash (using the fullpath as the key)
         #
         def build
           self.fetch_pages_from_config

           self.fetch_pages_from_filesystem

           self.build_relationships(self.pages['index'], self.pages_to_list)

           self.pages
         end

         protected

         # Create a ordered list of pages from the Hash
         #
         # @return [ Array ] An ordered list of pages
         #
         def pages_to_list
           # sort by fullpath first
           list = self.pages.values.sort { |a, b| a.fullpath <=> b.fullpath }
           # sort finally by depth
           list.sort { |a, b| a.depth <=> b.depth }
         end

         def build_relationships(parent, list)
           list.dup.each do |page|
             next unless self.is_subpage_of?(page.fullpath, parent.fullpath)

             # attach the page to the parent (order by position), also set the parent
             parent.add_child(page)

             # remove the page from the list
             list.delete(page)

             # go under
             self.build_relationships(page, list)
           end
         end

         # Record pages found in the config file
         def fetch_pages_from_config
           self.pages_from_config.each_with_index do |_page, position|
             fullpath, attributes = _page.keys.first.dasherize, _page.values.first.try(:symbolize_keys) || {}

             self.add_page(fullpath, attributes.merge(position: position))
           end
         end

         # Record pages found in file system
         def fetch_pages_from_filesystem
           Dir.glob(File.join(self.pages_root_dir, '**/*.{liquid,haml}')).each do |filepath|
             fullpath = self.filepath_to_fullpath(filepath)

             page = self.add_page(fullpath)

             I18n.with_locale(self.filepath_locale(filepath)) do
               page.template_filepath = filepath
             end
           end
         end

         # Add a new page in the global hash of pages.
         # If the page exists, then do nothing.
         #
         # @param [ String ] fullpath The fullpath used as the key for the hash
         # @param [ Hash ] attributes The attributes of the new page
         #
         # @return [ Object ] A newly created page or the existing one
         #
         def add_page(fullpath, attributes = {})
           unless self.pages.key?(fullpath)
             attributes[:fullpath] = fullpath
             self.pages[fullpath] = Locomotive::Mounter::Models::Page.new(attributes)
           end

           self.pages[fullpath]
         end

         # Shortcut to get the pages from the config fule
         #
         # @return [ Array ] The list of the pages described in the config file
         #
         def pages_from_config
           self.config['site']['pages'] || []
         end

         # Return the directory where all the templates of
         # pages are stored in the filesystem.
         #
         # @return [ String ] The root directory
         #
         def pages_root_dir
           File.join(self.runner.path, 'app', 'views', 'pages')
         end

         # Take the path to a file on the filesystem
         # and return its matching value for a Page.
         #
         # @param [ String ] filepath The path to the file
         #
         # @return [ String ] The fullpath of the page
         #
         def filepath_to_fullpath(filepath)
           fullpath = filepath.gsub(File.join(self.pages_root_dir, '/'), '')

           fullpath.gsub!(/^\.\//, '')

           fullpath.split('.').first.dasherize
         end

         # Return the locale of a file based on its extension.
         #
         # Ex: about_us/john_doe.fr.liquid => 'fr'
         #
         # @return [ String ] The locale (ex: fr, en, ...etc) or nil if it has no information about the locale
         #
         def filepath_locale(filepath)
           locale = File.basename(filepath).split('.')[1]

           locale && self.locales.include?(locale) ? locale : nil
         end

         # Tell is a page described by its fullpath is a sub page of a parent page
         # also described by its fullpath
         #
         # @param [ String ] fullpath The full path of the page to test
         # @param [ String ] parent_fullpath The full path of the parent page
         #
         # @return [ Boolean] True if the page is a sub page of the parent one
         #
         def is_subpage_of?(fullpath, parent_fullpath)
           return false if %w(index 404).include?(fullpath)

           if parent_fullpath == 'index' && fullpath.split('/').size == 1
             return true
           end

           File.dirname(fullpath.dasherize) == parent_fullpath.dasherize
         end

         # Output simply the tree structure of pages
         def to_s(page = nil)
           page ||= self.pages['index']

           puts "#{"  " * (page.depth + 1)} #{page.fullpath}"

           (page.children || []).each { |child| self.to_s(child) }
         end

       end

      end
    end
  end
end