module Locomotive
  module Mounter
    module Writer
      module Api
        class PagesWriter < Base

          attr_accessor :remote_translations

          def prepare
            super

            self.remote_translations = {}

            # get all the _id and parent_id
            self.get(:pages, nil, true).each do |attributes|
              page = self.pages[attributes['fullpath']]

              self.remote_translations[attributes['fullpath']] = attributes['translated_in']

              # puts "setting _id (#{attributes['_id']} and parent_id (#{attributes['parent_id']}) to #{page.fullpath}"

              page._id = attributes['_id'] if page
            end

            # assign the parent_id and the content_type_id to all the pages
            self.pages.values.each do |page|
              next if page.index_or_404?

              page.parent_id = page.parent._id

              # TODO: set content type for templatized page
            end
          end

          # Write all the pages to the remote destination
          def write
            self.mounting_point.locales.each do |locale|
              Locomotive::Mounter.with_locale(locale) do
                self.output_locale

                # first write the pages which are layouts for others
                self.layouts.each { |page| self.write_page(page) }

                # and proceed the others
                self.other_than_layouts.each { |page| self.write_page(page) }
              end
            end
          end

          protected

          def write_page(page)
            locale = Locomotive::Mounter.locale

            return unless page.translated_in?(locale)

            self.output_resource_op page

            # TODO: replace assets

            if page.persisted?
              # All the attributes of the page or just some of them
              params = self.force? || !self.already_translated?(page) ? page.to_params : page.to_safe_params

              # make a call to the API for the update
              self.put :pages, page._id, params, locale
            else
              if !page.index_or_404? && page.parent_id.nil?
                raise Mounter::WriterException.new("We are unable to find the parent page for #{page.fullpath}")
              end

              # make a call to the API to create the page, no need to set
              # the locale since it only happens for the default locale.
              object = self.post :pages, page.to_params, nil, true

              page._id = object['_id']
            end

            self.output_resource_op_status page
          end

          # Shortcut to get pages
          #
          # @return [ Hash ] The hash whose key is the fullpath and the value is the page itself
          #
          def pages
            self.mounting_point.pages
          end

          # Return the pages which are layouts for others.
          # They are sorted by the depth.
          #
          # @return [ Array ] The list of layouts
          #
          def layouts
            self.pages.values.find_all { |p| p.is_layout? }.sort { |a, b| a.depth <=> b.depth }
          end

          # Return the pages wich are not layouts for others.
          # They are sorted by both the depth and the position.
          #
          # @return [ Array ] The list of non-layout pages
          #
          def other_than_layouts
            list = (self.pages.values - self.layouts)

            # get only the translated ones in the current locale
            list.delete_if { |page| !page.translated_in?(Locomotive::Mounter.locale) }

            # sort them
            list.sort { |a, b| a.depth_and_position <=> b.depth_and_position }
          end

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

        end

      end
    end
  end
end