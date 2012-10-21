module Locomotive
  module Mounter
    module Writer
      module Api

        # Push content entries to a remote LocomotiveCMS engine.
        #
        # They get created or changed only if the
        # :content_entries option has been passed.
        #
        class ContentEntriesWriter < Base

          # attr_accessor :remote_translations

          attr_accessor :with_relationships

          def prepare
            super

            self.with_relationships = []

            # TODO
          end

          def write
            self.each_locale do |locale|
              self.output_locale

              self.content_types.each do |slug, content_type|

                (content_type.entries || []).each do |entry|
                  next unless entry.translated_in?(locale)

                  puts "content_entry = #{entry.to_params.inspect}"

                  if entry.persisted?
                    # TODO
                  else
                    # TODO
                  end
                end
              end
            end
          end

          protected

          # def entries_with_relationship(content_type)
          #   (content_type.entries || []).select { |entry| !entry.persisted? }
          # end

          def content_types
            self.mounting_point.content_types
          end

          # Take a content entry and get the params related to that content
          #
          # @param [ Object ] entry The content entry
          #
          # @return [ Hash ] The params
          #
          def content_entry_to_params(entry)

          end

        end
      end
    end
  end
end