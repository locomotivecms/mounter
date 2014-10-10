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
            theme_assets_array_opts = {}
            theme_assets_array_opts[:bower_config_path] = bower_config_path if File.file? bower_config_path

            ThemeAssetsArray.new(self.root_dir, theme_assets_array_opts)
          end

          protected

          # Return the directory where all the theme assets
          # are stored in the filesystem.
          #
          # @return [ String ] The theme assets directory
          #
          def root_dir
            File.join(self.runner.path, 'public')
          end

          def bower_used?
            File.exist?(bower_config_path) && File.exist?(bower_root_dir)
          end

          def bower_root_dir
            @bower_root_dir ||= JSON.parse(IO.read(bower_config_path))["directory"]
          end

          def bower_config_path
            File.join(self.runner.path, '.bowerrc')
          end

        end

      end

      class ThemeAssetsArray
        DEFAULT_IGNORED_FOLDER = ['samples']

        attr_accessor :root_dir, :ignored_folders

        def initialize(root_dir, opts={})
          self.root_dir = root_dir
          @bower_config_path = opts[:bower_config_path]
          @ignored_folders = DEFAULT_IGNORED_FOLDER.map{ |folder| File.join(self.root_dir, folder) }
          @ignored_folders.push(*opts[:ignored_folder_paths]).uniq!
        end

        def list
          return @list unless @list.nil?

          @list = []
          @list.tap do
            load_bower_assets if bower_used?
            load_public_assets
          end
        end

        def load_public_assets
          # Follows symlinks and makes sure subdirectories are handled
          glob_pattern = '**/*/**/*'

          Dir.glob(File.join(self.root_dir, glob_pattern)).each_with_object(@list) do |file, array|
            next if self.exclude?(file)

            folder = File.dirname(file.gsub("#{self.root_dir}/", ''))

            array.push Locomotive::Mounter::Models::ThemeAsset.new(folder: folder, filepath: file)
          end
        end

        def load_bower_assets
          bower_files_pattern = '**/bower.json'

          Dir.glob(File.join(self.bower_root_dir, bower_files_pattern)).each_with_object(@list) do |bower_file, array|
            bower_project_folder, _ = bower_file.split("/bower.json")

            [*JSON.parse(IO.read(bower_file))["main"]].each do |relative_file_path|
              filepath = File.expand_path File.join(bower_project_folder, relative_file_path)
              next if self.exclude?(filepath)

              folder = File.dirname(filepath)
              array.push Locomotive::Mounter::Models::ThemeAsset.new(folder: folder, filepath: filepath)
            end
          end
        end

        def bower_used?
          @bower_config_path.present? && File.file?(@bower_config_path) && File.exist?(bower_root_dir)
        end

        def bower_root_dir
          return @bower_root_dir if @bower_root_dir
          bower_relative_folder, _ = @bower_config_path.split("/.bowerrc")
          bower_folder = JSON.parse(IO.read(@bower_config_path))["directory"]
          @bower_root_dir = File.expand_path File.join(bower_relative_folder, bower_folder)
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
