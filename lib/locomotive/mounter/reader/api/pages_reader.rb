module Locomotive
  module Mounter
    module Reader
      module Api

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

            # index = self.pages['index']
            #
            # index.localize_fullpath(self.locales)
            #
            # self.build_relationships(index, self.pages_to_list)

            # Locomotive::Mounter.with_locale(:fr) { self.to_s } # DEBUG
            # puts self.to_s

            self.pages
          end

          protected


          # Record pages found in file system
          def fetch
            puts self.get(:pages).to_a.inspect

            # folders = []
            #
            # Dir.glob(File.join(self.root_dir, '**/*')).each do |filepath|
            #   fullpath = self.filepath_to_fullpath(filepath)
            #
            #   folders.push(fullpath) && next if File.directory?(filepath)
            #
            #   next unless filepath =~ /\.(#{Locomotive::Mounter::TEMPLATE_EXTENSIONS.join('|')})$/
            #
            #   page = self.add(fullpath)
            #
            #   Locomotive::Mounter.with_locale(self.filepath_locale(filepath)) do
            #     if Locomotive::Mounter.locale
            #       template = Tilt.new(filepath)
            #
            #       if template.respond_to?(:attributes)
            #         page.attributes = template.attributes
            #       end
            #
            #       page.template = template
            #     end
            #   end
            # end
            #
            # folders.each do |fullpath|
            #   next if self.pages.key?(fullpath)
            #   self.add(fullpath)
            # end
          end

          # Add a new page in the global hash of pages.
          # If the page exists, then do nothing.
          #
          # @param [ String ] fullpath The fullpath used as the key for the hash
          # @param [ Hash ] attributes The attributes of the new page
          #
          # @return [ Object ] A newly created page or the existing one
          #
          def add(fullpath, attributes = {})
            unless self.pages.key?(fullpath)
              attributes[:title]    = File.basename(fullpath).humanize
              attributes[:fullpath] = fullpath

              self.pages[fullpath]  = Locomotive::Mounter::Models::Page.new(attributes)
            end

            self.pages[fullpath]
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

          def safe_attributes
            %w(_id title slug handle fullpath
            published listed templatized
            redirect_url cache_strategy response_type position
            seo_title meta_keywords meta_description)
          end

          # Output simply the tree structure of the pages.
          #
          # Note: only for debug purpose
          #
          def to_s(page = nil)
            page ||= self.pages['index']

            puts "#{"  " * (page.try(:depth) + 1)} #{page.fullpath.inspect} (#{page.title}, position=#{page.position})"

            (page.children || []).each { |child| self.to_s(child) }
          end

        end

      end
    end
  end
end