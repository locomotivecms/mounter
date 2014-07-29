module Locomotive
  module Mounter
    module Writer
      module Api

        # Push pages to a remote LocomotiveCMS engine.
        #
        # New pages are created and existing ones are partially updated.
        #
        # If the :force option is passed, the existing pages are fully updated (title, ...etc).
        # But in any cases, the content of the page will be destroyed, unless the layout of the page
        # changes.
        #
        class PagesWriter < Base

          MAX_ATTEMPTS = 5

          attr_accessor :new_pages
          attr_accessor :remote_translations

          def prepare
            super

            self.new_pages, self.remote_translations = [], {}

            # set the unique identifier to each local page
            self.get(:pages, nil, true).each do |attributes|
              page = self.pages[attributes['fullpath'].dasherize]

              self.remote_translations[attributes['fullpath']] = attributes['translated_in']

              page._id = attributes['id'] if page
            end

            # assign the parent_id and the content_type_id to all the pages
            self.pages.values.each do |page|
              next if page.index_or_404?

              page.parent_id = page.parent._id
            end
          end

          # Write all the pages to the remote destination
          def write
            self.each_locale do |locale|
              self.output_locale

              done, attempts = {}, 0
              while done.size < pages.length - 1 && attempts < MAX_ATTEMPTS
                _write(pages['index'], done, done.size > 0)

                # keep track of the attempts because we don't want to get an infinite loop.
                attempts += 1
              end

              write_page(pages['404'])

              if done.size < pages.length - 1
                self.log %{Warning: NOT all the pages were pushed.\n\tCheck that the pages inheritance was done right OR that you translated all your pages.\n}.colorize(color: :red)
              end
            end
          end

          protected

          def _write(page, done, already_done = false)
            if self.safely_translated?(page)
              write_page(page) unless already_done
            else
              self.output_resource_op page
              self.output_resource_op_status page, :not_translated
            end

            # mark it as done
            done[page.fullpath] = true

            # loop over its children
            (page.children || []).sort_by(&:depth_and_position).each do |child|
              layout = child.layout
              layout = page.fullpath if layout && layout == 'parent'

              if done[child.fullpath].nil? && (!layout || done[layout])
                _write(child, done)
              end
            end
          end

          def write_page(page)
            locale = Locomotive::Mounter.locale

            return unless page.translated_in?(locale)

            self.output_resource_op page

            success = page.persisted? ? self.update_page(page) : self.create_page(page)

            self.output_resource_op_status page, success ? :success : :error

            self.flush_log_buffer
          end

          # Persist a page by calling the API. The returned _id
          # is then set to the page itself.
          #
          # @param [ Object ] page The page to create
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def create_page(page)
            if !page.index_or_404? && page.parent_id.nil?
              raise Mounter::WriterException.new("We are unable to find the parent page for #{page.fullpath}")
            end

            params = self.buffer_log { page_to_params(page) }

            # make a call to the API to create the page, no need to set
            # the locale since it first happens for the default locale.
            response = self.post :pages, params, nil, true

            if response
              page._id = response['id']
              self.new_pages << page._id
            end

            !response.nil?
          end

          # Update a page by calling the API.
          #
          # @param [ Object ] page The page to persist
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def update_page(page)
            locale  = Locomotive::Mounter.locale

            # All the attributes of the page or just some of them
            params = self.buffer_log do
              self.page_to_params(page, self.data? || !self.already_translated?(page))
            end

            # make a call to the API for the update
            response = self.put :pages, page._id, params, locale

            !response.nil?
          end

          # Shortcut to get pages.
          #
          # @return [ Hash ] The hash whose key is the fullpath and the value is the page itself
          #
          def pages
            self.mounting_point.pages
          end

          # # Return the pages which are layouts for others.
          # # They are sorted by the depth.
          # #
          # # @return [ Array ] The list of layouts
          # #
          # def layouts
          #   self.pages.values.find_all do |page|
          #     self.safely_translated?(page) && self.is_layout?(page)
          #   end.sort { |a, b| a.depth <=> b.depth }
          # end

          # # Return the pages wich are not layouts for others.
          # # They are sorted by both the depth and the position.
          # #
          # # @return [ Array ] The list of non-layout pages
          # #
          # def other_than_layouts
          #   list = (self.pages.values - self.layouts)

          #   # get only the translated ones in the current locale
          #   list.delete_if do |page|
          #     # if (!page.parent.nil? && !page.translated_in?(self.mounting_point.default_locale)) ||
          #     #   !page.translated_in?(Locomotive::Mounter.locale)
          #     if !self.safely_translated?(page)
          #       self.output_resource_op page
          #       self.output_resource_op_status page, :not_translated
          #       true
          #     end
          #   end

          #   # sort them
          #   list.sort { |a, b| a.depth_and_position <=> b.depth_and_position }
          # end

          # Tell if the page passed in parameter has already been
          # translated on the remote engine for the locale passed
          # as the second parameter.
          #
          # @param [ Object ] page The page
          # @param [ String / Symbol ] locale The locale. Use the current locale by default
          #
          # @return [ Boolean] True if already translated.
          #
          def already_translated?(page, locale = nil)
            locale ||= Locomotive::Mounter.locale

            (@remote_translations[page.fullpath] || []).include?(locale.to_s)
          end

          # Tell if the page is correctly localized, meaning it is localized itself
          # as well as its parent.
          #
          # @param [ Object ] page The page
          #
          # @return [ Boolean] True if safely translated.
          #
          def safely_translated?(page)
            if page.parent.nil?
              page.translated_in?(Locomotive::Mounter.locale)
            else
              page.parent.translated_in?(Locomotive::Mounter.locale) &&
              page.translated_in?(Locomotive::Mounter.locale)
            end
          end

          # # Tell if the page is a real layout, which means no extends tag inside
          # # and that at least one of the other pages reference it as a parent template.
          # #
          # # @param [ Object ] page The page
          # #
          # # @return [ Boolean] True if it is a real layout.
          # #
          # def is_layout?(page)
          #   if page.is_layout?
          #     # has child(ren) extending the page itself ?
          #     return true if (page.children || []).any? { |child| child.layout == 'parent' }

          #     fullpath = page.fullpath_in_default_locale

          #     # among all the pages, is there a page extending the page itself ?
          #     self.pages.values.any? { |_page| _page.fullpath_in_default_locale != fullpath && _page.layout == fullpath }
          #   else
          #     false # extends not present
          #   end
          # end

          # Return the parameters of a page sent by the API.
          # It includes the editable_elements if the data option is enabled or
          # if the page is a new one.
          #
          # @param [ Object ] page The page
          # @param [ Boolean ] safe If true the to_safe_params is called, otherwise to_params is applied.
          #
          # @return [ Hash ] The parameters of the page
          #
          def page_to_params(page, safe = false)
            (safe ? page.to_safe_params : page.to_params).tap do |params|
              # raw template
              params[:raw_template] = self.replace_content_assets!(params[:raw_template])

              if self.data? || self.new_pages.include?(page._id)
                params[:editable_elements] = (page.editable_elements || []).map(&:to_params)
              else
                params.delete(:editable_elements)
              end

              # editable elements
              (params[:editable_elements] || []).each do |element|
                if element[:content] =~ /^\/samples\//
                  element[:source] = self.path_to_file(element.delete(:content))
                elsif element[:content] =~ %r($http://)
                  element[:source_url] = element.delete(:content)
                else
                  # string / text elements
                  element[:content] = self.replace_content_assets!(element[:content])
                end
              end
            end
          end

        end

      end
    end
  end
end