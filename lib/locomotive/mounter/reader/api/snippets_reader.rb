module Locomotive
  module Mounter
    module Reader
      module Api

        class SnippetsReader < Base

          # Build the list of snippets from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of snippets
          #
          def read
            self.fetch

            self.items
          end

          protected

          # Record snippets found in file system
          def fetch
            self.get(:snippets).each do |attributes|
              snippet = self.add(attributes.delete('slug'), attributes)

              self.mounting_point.locales[1..-1].each do |locale|
                Locomotive::Mounter.with_locale(locale) do
                  localized_attributes = self.get("snippets/#{snippet._id}", locale)
                  snippet.attributes = localized_attributes
                end
              end
            end
          end

          # Add a new snippet in the global hash of snippets.
          # If the snippet exists, it returns it.

          # @param [ String ] slug The slug of the snippet
          # @param [ Hash ] attributes The attributes of the snippet
          #
          # @return [ Object ] A newly created snippet or the existing one
          #
          def add(slug, attributes)
            unless self.items.key?(slug)
              self.items[slug] = Locomotive::Mounter::Models::Snippet.new(attributes)
            end

            self.items[slug]
          end

          def safe_attributes
            %w(_id name slug template)
          end

        end

      end
    end
  end
end
