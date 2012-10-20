module Locomotive
  module Mounter
    module Writer
      module Api

        # Push content types to a remote LocomotiveCMS engine.
        #
        # In a first time, create the content types without any relationships fields.
        # Then, add the relationships one by one.
        #
        # The force option is not used.
        #
        class ContentTypesWriter < Base

          def prepare
            super

            # assign an _id to a local content type if possible
            self.get(:content_types, nil, true).each do |attributes|
              content_type = self.content_types[attributes['slug']]

              self.apply_response(content_type, attributes)
            end
          end

          def write
            done = {}

            # first new content types
            self.not_persisted.each do |content_type|
              self.create_content_type(content_type)

              done[content_type.slug] = content_type.with_relationships? ? :todo : :done
            end

            # then update the others
            self.content_types.values.each do |content_type|
              next unless done[content_type.slug].nil?

              self.update_content_type(content_type)
            end

            # finally, update the newly created embedding a relationship field
            done.each do |slug, status|
              next if status == :done

              content_type = self.content_types[slug]

              self.update_content_type(content_type)
            end
          end

          protected

          # Persist a content type by calling the API. It is enhanced then
          # by the response if no errors occured.
          #
          # @param [ Object ] content_type The content type to create
          #
          def create_content_type(content_type)
            self.output_resource_op content_type

            response = self.post :content_types, content_type.to_params, nil, true

            self.apply_response(content_type, response)

            status = self.response_to_status(response)

            self.output_resource_op_status content_type, status
          end

          # Update a content type by calling the API.
          #
          # @param [ Object ] content_type The content type to create
          #
          def update_content_type(content_type)
            self.output_resource_op content_type

            params = self.content_type_to_params(content_type)

            # make a call to the API for the update
            response = self.put :content_types, content_type._id, params

            status = self.response_to_status(response)

            raise 'STOP' if status != :success

            self.output_resource_op_status content_type, status
          end

          def content_types
            self.mounting_point.content_types
          end

          # Return the content types not persisted yet.
          #
          # @return [ Array ] The list of non persisted content types.
          #
          def not_persisted
            self.content_types.values.find_all { |content_type| !content_type.persisted? }
          end

          # Enhance the content type with the information returned by an API call.
          #
          # @param [ Object ] content_type The content type instance
          # @param [ Hash ] response The API response
          #
          def apply_response(content_type, response)
            return if content_type.nil? || response.nil?

            content_type._id = response['_id']
            content_type.klass_name = response['klass_name']

            response['entries_custom_fields'].each do |remote_field|
              field = content_type.find_field(remote_field['name'])
              _id   = remote_field['_id']

              if field.nil?
                content_type.fields << Locomotive::Mounter::Models::ContentField.new(_id: _id, _destroy: true)
              else
                field._id = _id
              end
            end
          end

          # Get the params of a content type and set
          # the appropriate klass_name taken from the remote side
          # in all the relationship fields.
          #
          # @param [ Object ] content_type The ContentType
          #
          # @return [ Hash ] The params of the ContentType ready to be used in the API
          #
          def content_type_to_params(content_type)
            content_type.to_params(all_fields: true).tap do |params|
              params[:entries_custom_fields_attributes].each do |attributes|
                if attributes[:class_name]
                  target_content_type = self.content_types[attributes[:class_name]]
                  attributes[:class_name] = target_content_type.klass_name
                end
              end
            end
          end

        end

      end
    end
  end
end