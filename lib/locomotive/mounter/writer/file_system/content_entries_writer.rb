module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class ContentEntriesWriter < Base

          # It creates the data folder
          def prepare
            self.create_folder 'data'
            # self.create_folder 'public/samples'
          end

          # It writes all the content types into files
          def write
            self.mounting_point.content_types.each do |filename, content_type|
              file_fields = content_type.fields.select {|f| f.type == :file}
              entries = (content_type.entries || []).map {|e| process_files(file_fields, e)}.map(&:to_hash)
             
              self.open_file("data/#{filename}.yml") do |file|
                file.write(entries.to_yaml)
              end
            end
          end
          
          
          def process_files(file_fields, entry)
            file_fields.each do |f|
              entry.dynamic_attributes[f.name.to_sym].tap do |item|
                unless item.nil?
                  if f.localized
                    item.each do |locale, path|
                      entry.dynamic_attributes[f.name.to_sym][locale] = copy_file entry, f.name, path, locale
                    end
                  else
                    entry.dynamic_attributes[f.name.to_sym] = copy_file entry, f.name, item
                  end
                end
              end
            end
            entry
          end

          
          def copy_file(entry, field, path, locale = nil)
            base_path = File.join target_path, "public"
            field_path = File.join "samples", entry.content_type.slug, entry._slug, field
            field_path = File.join field_path, locale.to_s if locale
            
            create_folder File.join base_path, field_path
            
            if path =~ /^https?:\/\//
              uri = URI(path)
              file = Net::HTTP.get(uri)
              filename = File.basename(uri.path)
            else
              file = File.read(path)
              filename = File.basename(path)
            end
            open_file(File.join(base_path, field_path, filename), 'wb') do |new_file|
              new_file.write(file)
            end
            File.join "/", field_path, filename
          end

        end
      end
    end
  end
end