module Locomotive
  module Mounter
    module Writer
      module Api

        # Push content entries to a remote LocomotiveCMS engine.
        #
        # They get created or changed only if the
        # :content_entries option has been passed.
        #
        # TODO:
        #   - steps:
        #     1/ insert entries without relationships
        #     2/ do 1/ for each locales
        #     3/ update each entry with relationships
        #     4/ update options (in each locale)
        #
        #
        class ContentEntriesWriter < Base

          attr_accessor :with_relationships

          def prepare
            super

            # initialize the list storing all the entries including relationships
            self.with_relationships = []

            # assign an _id to a local content entry if possible
            self.content_types.each do |slug, content_type|
              self.get("content_types/#{slug}/entries", nil, true).each do |attributes|
                content_entry = content_type.find_entry(attributes['_slug'])

                if content_entry
                  self.apply_response(content_entry, attributes)
                end
              end
            end
          end

          def write
            self.each_locale do |locale|
              self.output_locale

              self.content_types.each do |slug, content_type|
                (content_type.entries || []).each do |entry|
                  next unless entry.translated_in?(locale)

                  # DEBUG
                  # puts entry.dynamic_attributes.inspect
                  puts "content_entry = #{content_entry_to_params(entry).inspect}"

                  raise 'STOP' if locale.to_s == 'fr'

                  if entry.persisted?
                    self.update_content_entry(slug, entry)
                  else
                    self.create_content_entry(slug, entry)
                  end

                  self.register_relationships(entry)
                end # content entries
              end # content type
            end # locale

            self.persist_content_entry_with_relationships
          end

          protected

          # Persist a content entry by calling the API. It is enhanced then
          # by the response if no errors occured.
          #
          # @param [ String ] content_type The slug of the content type
          # @param [ Object ] content_entry The content entry to create
          #
          def create_content_entry(content_type, content_entry)
            # log before
            self.output_resource_op content_entry

            # get the params
            params = self.content_entry_to_params(content_entry)

            # send the request
            response = self.post "content_types/#{content_type}/entries", params, nil, true

            self.apply_response(content_entry, response)

            status = self.response_to_status(response)

            # log after
            self.output_resource_op_status content_entry, status
          end

          # Update a content entry by calling the API.
          #
          # @param [ String ] content_type The slug of the content type
          # @param [ Object ] content_entry The content entry to update
          #
          def update_content_entry(content_type, content_entry)
            # log before
            self.output_resource_op content_entry

            # get the params
            params = self.content_entry_to_params(content_entry)

            # send the request
            response = self.put "content_types/#{content_type}/entries", content_entry._id, params

            status = self.response_to_status(response)

            # log after
            self.output_resource_op_status content_entry, status
          end

          # Save to the remote engine the content entries owning
          # a relationship field. This can be done once ALL the
          # the content entries have been first created.
          #
          def persist_content_entry_with_relationships
            puts "self.with_relationships = #{self.with_relationships.inspect}"

            self.with_relationships.each do |content_entry|
              params = { _id: content_entry._id }

              content_entry.content_type.fields.each do |field|
                case field.type.to_sym
                when :belongs_to
                  target_id = content_entry.dynamic_getter(field.name).try(:_id)
                  params["#{field.name}_id"] = target_id
                when :many_to_many
                  target_ids = content_entry.dynamic_getter(field.name).map(&:_id)
                  params["#{field.name}_ids"] = target_ids
                end
              end

              puts "content entry to save: #{params.inspect}"
              # TODO: PERSIST
            end
          end

          # Return the list of content types
          #
          # @return [ Array ] List of content types
          #
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
            params = entry.to_params

            entry.each_dynamic_field do |field, value|
              case field.type.to_sym
              when :string, :text, :date, :select, :boolean
                params[field.name] = value
              when :file
                if value =~ %r($http://)
                  params[field.name] = value
                elsif self.mounting_point.path
                  path = File.join(self.mounting_point.path, 'public', value)
                  params[field.name] = File.new(path)
                end
              end
            end

            params
          end

          # Keep track of both the content entries which
          # includes a relationship field and also
          # the selection options.
          #
          # @param [ Object ] entry The content entry
          #
          def register_relationships(entry)
            entry.each_dynamic_field do |field, value|
              if %w(belongs_to many_to_many).include?(field.type.to_s)
                self.with_relationships << entry
                return # no need to go further and avoid duplicate entries
              end
            end
          end

          # Enhance the content entry with the information returned by an API call.
          #
          # @param [ Object ] content_entry The content entry instance
          # @param [ Hash ] response The API response
          #
          def apply_response(content_entry, response)
            return if content_entry.nil? || response.nil?

            content_entry._id = response['_id']
          end

        end
      end
    end
  end
end