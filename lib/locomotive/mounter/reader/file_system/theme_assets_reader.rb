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
            ThemeAssetsArray.new(self.root_dir)
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

        end

      end

      class ThemeAssetsArray

        attr_accessor :root_dir

        def initialize(root_dir)
          self.root_dir = root_dir
        end

        def list
          return @list unless @list.nil?
          assets_symlinked = %w{ fonts images stylesheets javascripts }.inject(true) do |status, a|
            status and File.symlink?(File.join(self.root_dir, a))
          end

          if assets_symlinked
            # Follows symlinks and makes sure subdirectories are handled
            glob_pattern = '**/*/**/*'
          else
            glob_pattern = '**/*'
          end

          @list = [].tap do |list|
            Dir.glob(File.join(self.root_dir, glob_pattern)).each do |file|
              next if self.exclude?(file)

              folder = File.dirname(file.gsub(self.root_dir, ''))

              asset = Locomotive::Mounter::Models::ThemeAsset.new(folder: folder, filepath: file)

              list << asset
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
          file.starts_with?(File.join(self.root_dir, 'samples')) ||
          File.basename(file).starts_with?('_')
        end

        # This class acts a proxy of an array
        def method_missing(name, *args, &block)
          self.list.send(name.to_sym, *args, &block)
        end

      end
    end
  end
end
