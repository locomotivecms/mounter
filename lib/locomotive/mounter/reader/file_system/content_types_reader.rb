module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ContentTypesReader < Base

          # Build the list of content types from the folder in the file system.
          #
          # @return [ Array ] The un-ordered list of content types
          #
          def read
            self.fetch_from_filesystem

            self.items
          end

          protected

          def fetch_from_filesystem
            Dir.glob(File.join(self.root_dir, '*.yml')).each do |filepath|
              attributes = self.read_yaml(filepath)

              self.add(attributes)
            end
          end

          # Add a new content type in the global hash of content types.
          # If the content type exists, it returns it.
          #
          # @param [ Hash ] attributes The attributes of the content type
          #
          # @return [ Object ] A newly created content type or the existing one
          #
          def add(attributes)
            slug = attributes['slug']

            # TODO: raise an error if no fields

            attributes.delete('fields').each_with_index do |_attributes, index|
              hash = { name: _attributes.keys.first, position: index }.merge(_attributes.values.first)

              if options = hash.delete('select_options')
                hash['select_options'] = self.sanitize_select_options(options)
              end

              (attributes['fields'] ||= []) << hash
            end

            attributes[:mounting_point] = self.mounting_point

            unless self.items.key?(slug)
              self.items[slug] = Locomotive::Mounter::Models::ContentType.new(attributes)
            end

            self.items[slug]
          end

          # Take the list of options described in the YAML file
          # and convert it into a nice array of hashes
          #
          # @params [ Array ] options The list of raw options
          #
          # @return [ Array ] The sanitized list of options
          #
          def sanitize_select_options(options)
            [].tap do |array|
              if options.is_a?(Hash)
                options.each do |locale, values|
                  values.each_with_index do |value, position|
                    if _option = array[position]
                      _option[:name][locale] = value
                    else
                      array << { name: { locale => value }, position: position }
                    end
                  end
                end
              else
                options.each_with_index do |object, position|
                  array << { name: object, position: position }
                end
              end
            end
          end

          # Return the directory where all the definition of
          # the content types are stored.
          #
          # @return [ String ] The content types directory
          #
          def root_dir
            File.join(self.runner.path, 'app', 'content_types')
          end

        end

      end
    end
  end
end
