module Locomotive
  module Mounter
    module Writer
      module Api

        # Push content entries to a remote LocomotiveCMS engine.
        #
        # TODO: They get created or changed only if the
        # :data option has been passed.
        #
        class ContentEntriesWriter < Base

          attr_accessor :with_relationships

          def prepare
            return unless self.data?

            super

            # initialize the list storing all the entries including relationships
            self.with_relationships = []

            # assign an _id to a local content entry if possible
            self.content_types.each do |slug, content_type|
              entries = self.get("content_types/#{slug}/entries", nil, true)

              entries.each do |attributes|
                content_entry = content_type.find_entry(attributes['_slug'])

                if content_entry
                  self.apply_response(content_entry, attributes)
                end
              end
            end
          end

          def write
            return unless self.data?

            self.each_locale do |locale|
              self.output_locale

              self.content_types.each do |slug, content_type|
                (content_type.entries || []).each do |entry|
                  next unless entry.translated_in?(locale)

                  if entry.persisted?
                    self.update_content_entry(slug, entry)
                  else
                    self.create_content_entry(slug, entry)
                  end

                  self.register_relationships(slug, entry)
                end # content entries
              end # content type
            end # locale

            self.persist_content_entries_with_relationships
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
            params = self.buffer_log { self.content_entry_to_params(content_entry) }

            # send the request
            response = self.post "content_types/#{content_type}/entries", params, nil, true

            self.apply_response(content_entry, response)

            status = self.response_to_status(response)

            # log after
            self.output_resource_op_status content_entry, status
            self.flush_log_buffer
          end

          # Update a content entry by calling the API.
          #
          # @param [ String ] content_type The slug of the content type
          # @param [ Object ] content_entry The content entry to update
          #
          def update_content_entry(content_type, content_entry)
            locale  = Locomotive::Mounter.locale

            # log before
            self.output_resource_op content_entry

            # get the params
            params = self.buffer_log { self.content_entry_to_params(content_entry) }

            # send the request
            response = self.put "content_types/#{content_type}/entries", content_entry._id, params, locale

            status = self.response_to_status(response)

            # log after
            self.output_resource_op_status content_entry, status
            self.flush_log_buffer
          end

          # Save to the remote engine the content entries owning
          # a relationship field. This can be done once ALL the
          # the content entries have been first created.
          #
          def persist_content_entries_with_relationships
            unless self.with_relationships.empty?
              self.log "\n    setting relationships for all the content entries\n"

              updates = self.content_entries_with_relationships_to_hash

              updates.each do |params|
                _id, slug = params.delete(:_id), params.delete(:slug)
                self.put "content_types/#{slug}/entries", _id, params
              end
            end
          end

          # Build hash storing the values of the relationships (belongs_to and has_many).
          # The key is the id of the content entry
          #
          # @return [ Hash ] The updates to process
          #
          def content_entries_with_relationships_to_hash
            [].tap do |updates|
              self.with_relationships.each do |(slug, content_entry)|
                changes = {}

                content_entry.content_type.fields.each do |field|
                  case field.type.to_sym
                  when :belongs_to
                    if target_id = content_entry.dynamic_getter(field.name).try(:_id)
                      changes["#{field.name}_id"] = target_id
                    end
                  when :many_to_many
                    target_ids = content_entry.dynamic_getter(field.name).map(&:_id).compact
                    unless target_ids.empty?
                      changes["#{field.name}_ids"] = target_ids
                    end
                  end
                end

                updates << { _id: content_entry._id, slug: slug }.merge(changes)
              end
            end
          end

          # Return the list of content types
          #
          # @return [ Array ] List of content types
          #
          def content_types
            self.mounting_point.content_types
          end

          # Take a content entry and get the params related to that content entry.
          #
          # @param [ Object ] entry The content entry
          #
          # @return [ Hash ] The params
          #
          def content_entry_to_params(entry)
            params = entry.to_params

            entry.each_dynamic_field do |field, value|
              unless field.is_relationship?
                case field.type.to_sym
                when :string, :text
                  params[field.name] = self.replace_content_assets!(value)
                when :file
                  if value =~ %r(^http://)
                    params[field.name] = value
                  elsif value && self.mounting_point.path
                    path = File.join(self.mounting_point.path, 'public', value)
                    params[field.name] = File.new(path)
                  end
                else
                  params[field.name] = value
                end
              end
            end

            params
          end

          # Keep track of both the content entries which
          # includes a relationship field and also
          # the selection options.
          #
          # @param [ String ] slug The slug of the content type
          # @param [ Object ] entry The content entry
          #
          def register_relationships(slug, entry)
            entry.each_dynamic_field do |field, value|
              if %w(belongs_to many_to_many).include?(field.type.to_s)
                self.with_relationships << [slug, entry]
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
