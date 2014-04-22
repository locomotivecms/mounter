module Locomotive
  module Mounter
    module Writer
      module Api

        # Push snippets to a remote LocomotiveCMS engine.
        #
        # The force option is not used.
        #
        class SnippetsWriter < Base

          def prepare
            super

            # set the unique identifier to each local snippet
            self.get(:snippets, nil, true).each do |attributes|
              snippet = self.snippets[attributes['slug']]

              snippet._id = attributes['id'] if snippet
            end
          end

          # Write all the snippets to the remote destination
          def write
            self.each_locale do |locale|
              self.output_locale

              self.snippets.each { |snippet| self.write_snippet(snippet) }
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

            success = snippet.persisted? ? self.update_snippet(snippet) : self.create_snippet(snippet)

            self.output_resource_op_status snippet, success ? :success : :error
            self.flush_log_buffer
          end

          # Persist a snippet by calling the API. The returned id
          # is then set to the snippet itself.
          #
          # @param [ Object ] snippet The snippet to create
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def create_snippet(snippet)
            params = self.buffer_log { snippet_to_params(snippet) }

            # make a call to the API to create the snippet, no need to set
            # the locale since it first happens for the default locale.
            response = self.post :snippets, params, nil, true

            snippet._id = response['id'] if response

            !response.nil?
          end

          # Update a snippet by calling the API.
          #
          # @param [ Object ] snippet The snippet to persist
          #
          # @return [ Boolean ] True if the call to the API succeeded
          #
          def update_snippet(snippet)
            params = self.buffer_log { snippet_to_params(snippet) }

            locale = Locomotive::Mounter.locale

            # make a call to the API for the update
            response = self.put :snippets, snippet._id, params, locale

            !response.nil?
          end

          # Shortcut to get all the local snippets.
          #
          # @return [ Hash ] The hash whose key is the slug and the value is the snippet itself
          #
          def snippets
            self.mounting_point.snippets
          end

          # Return the parameters of a snippet sent by the API.
          #
          # @param [ Object ] snippet The snippet
          #
          # @return [ Hash ] The parameters of the page
          #
          def snippet_to_params(snippet)
            snippet.to_params.tap do |params|
              params[:template] = self.replace_content_assets!(params[:template])
            end
          end

        end
      end
    end
  end
end