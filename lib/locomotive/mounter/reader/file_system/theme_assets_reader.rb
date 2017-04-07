module Locomotive
  module Mounter
    module Reader
      module FileSystem

        class ThemeAssetsReader < Base

          # Build the list of theme assets from the public folder with eager loading.
          #
          # @return [ Array ] The cached list of theme assets
          #
          def read
            ThemeAssetsArray.new(self.runner.path)
          end

        end

      end

      class ThemeAssetsArray
        DEFAULT_IGNORED_FOLDER = ['samples']
        ASSETS_FODLERS = {
          bower: 'bower_components',
          public: 'public'
        }

        attr_accessor :root_dir, :ignored_folders

        def initialize(root_dir)
          self.root_dir = root_dir
          @ignored_folders = DEFAULT_IGNORED_FOLDER.map{ |folder| File.join(self.root_dir, folder) }
        end

        def list
          return @list unless @list.nil?

          @list = []
          load_bower_assets
          load_public_assets
          @list
        end

        def load_public_assets
          # Follows symlinks and makes sure subdirectories are handled
          glob_pattern = '**/*/**/*'

          Dir.glob(File.join(self.root_dir, 'public', glob_pattern)).each_with_object(@list) do |file, array|
            next if self.exclude?(file)

            folder = File.dirname(file.gsub("#{self.root_dir}/public/", ''))

            array.push Locomotive::Mounter::Models::ThemeAsset.new(folder: folder, filepath: file)
          end
        end

        def load_bower_assets
          bower_files_pattern = '**/bower.json'

          Dir.glob(File.join(self.root_dir, 'bower_components',  bower_files_pattern)).each_with_object(@list) do |bower_file, array|
            bower_project_folder, _ = bower_file.split("/bower.json")

            [*JSON.parse(IO.read(bower_file))["main"]].each do |relative_file_path|
              file = File.join(bower_project_folder, relative_file_path)
              next if self.exclude?(file)

              folder = File.dirname(file.gsub("#{self.root_dir}/", ''))
              array.push Locomotive::Mounter::Models::ThemeAsset.new(folder: folder, filepath: file)
            end
          end
        end

        alias :values :list

        # Tell if the file has to be excluded from the array
        # of theme assets. It does not have to be a folder
        # or be in the samples folder or owns a name starting with
        # the underscore character.
        #
        # @param [ String ] file The full path to the file
        #
        # @return [ Boolean ] True if it does not have to be included in the list.
        #
        def exclude?(file)
          File.directory?(file) ||
            File.basename(file).starts_with?('_') ||
            ignored_folders.any? {|dir| file.starts_with? dir }
        end

        # This class acts a proxy of an array
        def method_missing(name, *args, &block)
          super unless self.list.respond_to?(name.to_sym)
          self.list.send(name.to_sym, *args, &block)
        end

      end

    end
  end
end
