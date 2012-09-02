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

            index = self.pages['index']

            self.build_relationships(index, self.pages_to_list)

            # Locomotive::Mounter.with_locale(:fr) { self.to_s } # DEBUG
            # self.to_s

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

          # Record pages found in file system
          def fetch
            self.get(:pages).each do |attributes|
              page = self.add(attributes['fullpath'], attributes)

              self.mounting_point.locales[1..-1].each do |locale|
                # if not translated, no need to make an api call for that locale
                next unless page.translated_in?(locale)

                Locomotive::Mounter.with_locale(locale) do
                  localized_attributes = self.get("pages/#{page._id}", locale)
                  page.attributes = localized_attributes
                end
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
          def add(fullpath, attributes = {})
            unless self.pages.key?(fullpath)
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
            %w(_id title slug handle fullpath translated_in
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

            return unless page.translated_in?(Locomotive::Mounter.locale)

            puts "#{"  " * (page.try(:depth) + 1)} #{page.fullpath.inspect} (#{page.title}, position=#{page.position})"

            (page.children || []).each { |child| self.to_s(child) }
          end

        end

      end
    end
  end
end