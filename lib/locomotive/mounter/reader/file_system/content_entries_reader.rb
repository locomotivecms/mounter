module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentEntriesReader < Base

          # Build the list of content types from the folder on the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read

            self.items = Collection.new(self)
          end

          def all_slugs
            raise 'TODO'
          end

          def fetch_one slug
            content_type, entry_slug = get_content_type(slug.first), slug.last
            entries[content_type][entry_slug]
          end

          protected

          def entries
            @entries ||= Hash.new do |hsh, content_type|
              hsh[content_type] = {}.tap do |entries_hsh|
                begin
                  attributes = read_yaml File.join(self.root_dir, "#{content_type.slug}.yml")
                  attributes.each_with_index do |_attributes, index|
                    entry = build_entry(content_type, _attributes, index)
                    entries_hsh[entry._slug] = entry
                  end
                rescue Errno::ENOENT; end
              end
            end
          end

          # Get the content type identified by the slug from the mounting point.
          # Raise an UnknownContentTypeException exception if such a content type
          # does not exist.
          #
          # @param [ String ] slug The slug of the content type
          #
          # @return [ Object ] The instance of the content type
          #
          def get_content_type(slug)
            self.mounting_point.content_types[slug.to_s].tap do |content_type|
              if content_type.nil?
                raise UnknownContentTypeException.new("unknow content type #{slug.inspect}")
              end
            end
          end

          # Add a content entry for a content type.
          #
          # @param [ Object ] content_type The content type
          # @param [ Hash ] attributes The attributes of the content entry
          # @param [ Integer ] position The position of the entry in the list
          #
          def build_entry(content_type, attributes, position)
            if attributes.is_a?(String)
              label, _attributes = attributes, {}
            else
              label, _attributes = attributes.keys.first, attributes.values.first
            end

            # check if the label_field is localized or not
            label_field_name = content_type.label_field_name

            if content_type.label_field.localized && _attributes.key?(label_field_name) && _attributes[label_field_name].is_a?(Hash)
              _attributes[label_field_name].merge!(Locomotive::Mounter.locale => label).symbolize_keys!
            else
              _attributes[label_field_name] = label
            end

            _attributes[:_position] = position
            content_type.build_entry _attributes
          end

          # Return the directory where all the entries
          # of the content types are stored.
          #
          # @return [ String ] The content entries root directory
          #
          def root_dir
            File.join(self.runner.path, 'data')
          end

        end

      end
    end
  end
end