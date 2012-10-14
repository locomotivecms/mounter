module Locomotive
  module Mounter
    module Writer
      module Api
        class SnippetsWriter < Base

          def prepare
            super

            # get all the _id
            self.get(:snippets, nil, true).each do |attributes|
              snippet = self.snippets[attributes['slug']]

              snippet._id = attributes['_id'] if snippet
            end
          end

          # Write all the snippets to the remote destination
          def write
            self.mounting_point.locales.each do |locale|
              Locomotive::Mounter.with_locale(locale) do
                self.output_locale

                self.snippets.values.each { |snippet| self.write_snippet(snippet) }
              end
            end
          end

          protected

          # Write a snippet by calling the API.
          #
          # @param [ Object ] snippet The snippet
          #
          def write_snippet(snippet)
            locale = Locomotive::Mounter.locale

            return unless snippet.translated_in?(locale)

            self.output_resource_op snippet

            # TODO: replace assets

            success = snippet.persisted? ? self.update_snippet(snippet) : self.create_snippet(snippet)

            self.output_resource_op_status snippet, success
          end

          # Persist a snippet by calling the API. The returned _id
          # is then set to the snippet itself.
          #
          # @param [ Object ] snippet The snippet to update
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def create_snippet(snippet)
            # make a call to the API to create the snippet, no need to set
            # the locale since it first happens for the default locale.
            object = self.post :snippets, snippet.to_params, nil, true

            snippet._id = object['_id'] if object

            !object.nil?
          end

          # Update a snippet by calling the API.
          #
          # @param [ Object ] snippet The snippet to persist
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def update_snippet(snippet)
            locale = Locomotive::Mounter.locale

            # make a call to the API for the update
            object = self.put :snippets, snippet._id, snippet.to_params, locale

            !object.nil?
          end

          # Shortcut to get all the local snippets.
          #
          # @return [ Hash ] The hash whose key is the slug and the value is the snippet itself
          #
          def snippets
            self.mounting_point.snippets
          end

        end
      end
    end
  end
end