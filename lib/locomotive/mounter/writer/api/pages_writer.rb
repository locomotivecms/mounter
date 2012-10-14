module Locomotive
  module Mounter
    module Writer
      module Api
        class PagesWriter < Base

          def prepare
            super

            # get all the _id and parent_id
            self.get(:pages, nil, true).each do |attributes|
              page = self.pages[attributes['fullpath']]

              if page
                # puts "setting _id (#{attributes['_id']} and parent_id (#{attributes['parent_id']}) to #{page.fullpath}"
                page._id        = attributes['_id']
              end
            end

            # assigns parent_id
            self.pages.values.each do |page|
              next if page.index_or_404?

              page.parent_id = page.parent._id
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

            if page.persisted?
              # make a call to the API for the update
              self.put :page, page._id, page.site.to_hash(false), locale
            else
              if !page.index_or_404? && page.parent_id.nil?
                raise Mounter::WriterException.new("We are unable to find the parent page for #{page.fullpath}")
              end

              # TODO
              page._id = '42'
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

          def other_than_layouts
            list = (self.pages.values - self.layouts)

            # get only the translated ones in the current locale
            list.delete_if { |page| !page.translated_in?(Locomotive::Mounter.locale) }

            # sort them
            list.sort { |a, b| a.depth <=> b.depth }
          end

        end

      end
    end
  end
end