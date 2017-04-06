module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class PagesReader < Base

          attr_accessor :pages

          def initialize(runner)
            self.pages = {}
            super
          end

          # Build the tree of pages based on the filesystem structure
          #
          # @return [ Hash ] The pages organized as a Hash (using the fullpath as the key)
          #
          def read
            self.fetch

            index, not_found = self.pages['index'], self.pages['404']

            # localize the fullpath for the 2 core pages: index and 404
            [index, not_found].each { |p| p.localize_fullpath(self.locales) }

            self.build_relationships(index, self.pages_to_list)

            # Locomotive::Mounter.with_locale(:en) { self.to_s } # DEBUG

            # Locomotive::Mounter.with_locale(:fr) { self.to_s } # DEBUG

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
            # do not use an empty template for other locales than the default one
            parent.set_default_template_for_each_locale(self.default_locale)

            list.dup.each do |page|
              # comparing filepath to find out the ascendant/descendant relationship
              next unless self.is_subpage_of?(filepath_to_fullpath(page.filepath), filepath_to_fullpath(parent.filepath))

              # attach the page to the parent (order by position), also set the parent
              parent.add_child(page)

              # localize the fullpath in all the locales
              page.localize_fullpath

              # remove the page from the list
              list.delete(page)

              # go under
              self.build_relationships(page, list)
            end
          end

          # Record pages found in file system
          def fetch
            position, last_dirname = nil, nil

            Dir.glob(File.join(self.root_dir, '**/*')).sort.each do |filepath|
              next unless File.directory?(filepath) || filepath =~ /\.(#{Locomotive::Mounter::TEMPLATE_EXTENSIONS.join('|')})$/

              if last_dirname != File.dirname(filepath)
                position, last_dirname = 100, File.dirname(filepath)
              end

              page = self.add(filepath, position: position)

              next if File.directory?(filepath) || page.nil?

              if locale = self.filepath_locale(filepath)
                Locomotive::Mounter.with_locale(locale) do
                  self.set_attributes_from_header(page, filepath)
                end
              else
                Locomotive::Mounter.logger.warn "Unknown locale in the '#{File.basename(filepath)}' file."
              end

              position += 1
            end
          end

          # Add a new page in the global hash of pages.
          # If the page exists, override it.
          #
          # @param [ String ] filepath The path of the template
          # @param [ Hash ] attributes The attributes of the new page
          #
          # @return [ Object ] A newly created page or the existing one
          #
          def add(filepath, attributes = {})
            fullpath = self.filepath_to_fullpath(filepath)

            unless self.pages.key?(fullpath)
              attributes[:title]    = File.basename(fullpath).humanize
              attributes[:fullpath] = fullpath

              page = Locomotive::Mounter::Models::Page.new(attributes)
              page.mounting_point = self.mounting_point
              page.filepath       = File.expand_path(filepath)

              page.template = OpenStruct.new(raw_source: '') if File.directory?(filepath)

              self.pages[fullpath] = page
            end

            self.pages[fullpath]
          end

          # Set attributes of a page from the information
          # stored in the header of the template (YAML matters).
          # It also stores the template.
          #
          # @param [ Object ] page The page
          # @param [ String ] filepath The path of the template
          #
          def set_attributes_from_header(page, filepath)
            template = Locomotive::Mounter::Utils::YAMLFrontMattersTemplate.new(filepath)

            if template.attributes
              attributes = template.attributes.clone

              # set the editable elements
              page.set_editable_elements(attributes.delete('editable_elements'))

              # set the content type
              if content_type_slug = attributes.delete('content_type')
                attributes['templatized']   = true
                attributes['content_type']  = self.mounting_point.content_types.values.find { |ct| ct.slug == content_type_slug }
              end

              page.attributes = attributes
            end

            page.template = template
          end

          # Return the directory where all the templates of
          # pages are stored in the filesystem.
          #
          # @return [ String ] The root directory
          #
          def root_dir
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
            _filepath = File.expand_path(filepath)
            _rootpath = File.expand_path(self.root_dir)

            fullpath = _filepath.gsub(File.join(_rootpath, '/'), '')

            fullpath.gsub!(/^\.\//, '')

            fullpath.split('.').first.dasherize
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

          # Output simply the tree structure of the pages.
          #
          # Note: only for debug purpose
          #
          def to_s(page = nil)
            page ||= self.pages['index']

            puts "#{"  " * (page.try(:depth) + 1)} #{page.fullpath.inspect} (#{page.title}, position=#{page.position}, template=#{page.template_translations.keys.inspect})"

            (page.children || []).each { |child| self.to_s(child) }
          end

        end

      end
    end
  end
end
