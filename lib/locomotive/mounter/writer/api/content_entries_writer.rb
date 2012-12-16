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

          attr_accessor :with_relationships, :select_options

          def prepare
            super

            # assign an _id to a local content entry if possible
            self.content_types.each do |slug, content_type|
              self.get("/content_types/#{slug}/entries", nil, true).each do |attributes|
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
                self.with_relationships = []
                self.select_options     = {}

                (content_type.entries || []).each do |entry|
                  next unless entry.translated_in?(locale)

                  # DEBUG
                  puts "content_entry = #{content_entry_to_params(entry).inspect}"

                  if entry.persisted?
                    # self.create_content_entry(entry)
                  else
                    # self.update_content_entry(entry)
                  end

                  self.register_select_otions_and_relationships(entry)
                end # content entries

                self.persist_select_options(content_type, self.select_options)
              end # content type

              self.persist_content_entry_with_relationships(self.with_relationships)
            end # locale
          end

          protected

          # Persist a content type by calling the API. It is enhanced then
          # by the response if no errors occured.
          #
          # @param [ Object ] content_type The content type to create
          #
          def create_content_entry(content_entry)
            self.output_resource_op content_entry

            params = self.content_entry_to_params(content_entry)

            response = self.post :content_entries, params, nil, true

            self.apply_response(content_entry, response)

            status = self.response_to_status(response)

            self.output_resource_op_status content_entry, status
          end

          # Update a content entry by calling the API.
          #
          # @param [ Object ] content_entry The content entry to update
          #
          def update_content_entry(content_entry)
            self.output_resource_op content_entry

            params = self.content_entry_to_params(content_entry)

            # make a call to the API for the update
            response = self.put :content_entries, content_entry._id, params

            status = self.response_to_status(response)

            self.output_resource_op_status content_entry, status
          end

          # Create the list of options found in the content entries
          # of a particular content type.
          # It works even if the content type contains multiple
          # select field.
          #
          # @param [ Object ] content_type The content type
          # @param [ Array ] select_options List of select options by field
          #
          def persist_select_options(content_type, select_options)
            params = { _id: content_type._id, entries_custom_fields: [] }

            select_options.each do |name, list|
              field   = content_type.find_field(name)

              _params = { _id: field._id, select_options: [] }

              list.each_with_index do |option_name, position|
                # add only those which do not exist yet
                unless field.find_select_option(option_name)
                  _params[:select_options] << { name: option_name, position: position }
                end
              end

              params[:entries_custom_fields] << _params
            end

            puts "content type to save: #{params.inspect}"
            # TODO: PERSIST
          end

          # Save to the remote engine the content entries owning
          # a relationship field. This can be done once ALL the
          # the content entries have been first created.
          #
          # @params [ Array ] list The list of content entries
          #
          def persist_content_entry_with_relationships(list)
            list.each do |content_entry|
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
              when :string, :text, :date, :boolean
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
          def register_select_otions_and_relationships(entry)
            entry.each_dynamic_field do |field, value|
              case field.type.to_sym
              when :select
                self.register_select_option(field.name, value)
              when :belongs_to
                self.with_relationships << entry
              end
            end
          end

          # Push the value of a select field into a list.
          # This is also scoped by the current locale,
          # returned by Locomotive::Mounter.locale.
          # That list will be used to enhance the content type.
          #
          # @param [ String ] name The select field name
          # @param [ String ] value
          #
          def register_select_option(name, value)
            locale  = Locomotive::Mounter.locale

            self.select_options[name] ||= {}

            self.select_options[name][locale] ||= []
            unless self.select_options[name][locale].include?(value)
              self.select_options[name][locale] << value
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