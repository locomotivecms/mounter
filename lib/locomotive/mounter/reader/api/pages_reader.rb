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

            # Locomotive::Mounter.with_locale(:en) { self.to_s } # DEBUG

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
              next unless self.is_subpage_of?(page, parent)

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
            self.get(:pages).each do |attributes|
              page = self.add(attributes['fullpath'], attributes)

              self.mounting_point.locales[1..-1].each do |locale|
                # if not translated, no need to make an api call for that locale
                next unless page.translated_in?(locale)

                Locomotive::Mounter.with_locale(locale) do
                  localized_attributes = self.get("pages/#{page._id}", locale)

                  # remove useless non localized attributes
                  localized_attributes.delete('target_klass_slug')

                  # isolate the editable elements
                  editable_elements = self.filter_editable_elements(localized_attributes.delete('editable_elements'))

                  page.attributes = localized_attributes

                  page.set_editable_elements(editable_elements)
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
              # editable elements
              editable_elements = self.filter_editable_elements(attributes.delete('editable_elements'))

              # content type
              if content_type_slug = attributes.delete('target_klass_slug')
                attributes['content_type'] = self.mounting_point.content_types[content_type_slug] #.values.find { |ct| ct._id == content_type_id }
              end

              self.pages[fullpath] = Locomotive::Mounter::Models::Page.new(attributes)

              self.pages[fullpath].set_editable_elements(editable_elements)
            end

            self.pages[fullpath]
          end

          # Tell is a page described is a sub page of a parent page
          #
          # @param [ Object ] page The full path of the page to test
          # @param [ Object ] parent The full path of the parent page
          #
          # @return [ Boolean] True if the page is a sub page of the parent one
          #
          def is_subpage_of?(page, parent)
            return false if page.index_or_404?

            if page.parent_id # only in the new version of the engine
              return page.parent_id == parent._id
            end

            if parent.fullpath == 'index' && page.fullpath.split('/').size == 1
              return true
            end

            File.dirname(page.fullpath.dasherize) == parent.fullpath.dasherize
          end

          # Only keep the minimal attributes from a list of
          # editable elements hashes. It also replaces the url to
          # content assets by their corresponding local ones.
          #
          # @param [ Array ] list The list of the editable elements with all the attributes
          #
          # @return [ Array ] The list of editable elements with the right attributes
          #
          def filter_editable_elements(list)
            list.map do |attributes|
              type = attributes['type']
              attributes.keep_if { |k, _| %w(_id block slug content).include?(k) }.tap do |hash|
                unless hash['content'].blank?
                  if type == 'EditableFile'
                    hash['content'] = self.add_content_asset(hash['content'], '/samples/pages')
                  else
                    self.mounting_point.content_assets.each do |path, asset|
                      hash['content'].gsub!(path, asset.local_filepath)
                    end
                  end
                end
              end
            end
          end

          def safe_attributes
            %w(_id title slug handle fullpath translated_in
            parent_id target_klass_slug
            published listed templatized editable_elements
            redirect_url cache_strategy response_type position
            seo_title meta_keywords meta_description raw_template
            created_at updated_at)
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