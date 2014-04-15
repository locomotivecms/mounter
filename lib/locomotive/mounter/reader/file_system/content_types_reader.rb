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

            self.items = Collection.new self

          end


          def read_one slug
            self.read_yaml File.join(self.root_dir, "#{slug}.yml")
          end

          def all_slugs
            Dir.glob(File.join(self.root_dir, '*.yml')).map(&method(:filepath_to_slug))
          end

          # Add a new content type in the global hash of content types.
          # If the content type exists, it returns it.
          #
          # @param [ Hash ] attributes The attributes of the content type
          #
          # @return [ Object ] A newly created content type or the existing one
          #
          def fetch_one(slug)
            # TODO: raise an error if no fields
            attributes = read_one(slug)
            attributes.delete('fields').each_with_index do |_attributes, index|
              hash = { name: _attributes.keys.first, position: index }.merge(_attributes.values.first)

              if options = hash.delete('select_options')
                hash['select_options'] = self.sanitize_select_options(options)
              end

              (attributes['fields'] ||= []) << hash
            end

            attributes[:mounting_point] = self.mounting_point

            Locomotive::Mounter::Models::ContentType.new(attributes)
          end

          protected

          # Take the list of options described in the YAML file
          # and convert it into a nice array of hashes
          #
          # @params [ Array ] options The list of raw options
          #
          # @return [ Array ] The sanitized list of options
          #
          def sanitize_select_options(options)
            [].tap do |array|
              options.each_with_index do |object, position|
                array << { name: object, position: position }
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