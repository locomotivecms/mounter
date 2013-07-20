module Locomotive
  module Mounter
    module Writer
      module FileSystem

        class Base

          include Locomotive::Mounter::Utils::Output

          attr_accessor :mounting_point, :runner

          def initialize(mounting_point, runner)
            self.mounting_point = mounting_point
            self.runner         = runner
          end

          # It should always be called before executing the write method.
          # Writers inheriting from this class can overide it
          #
          def prepare
            self.output_title(:writing)
          end

          # Writers inheriting from this class *must* overide it
          def write
            raise 'The write method has to be overridden'
          end

          # Helper method to create a folder from a relative path
          #
          # @param [ String ] path The relative path
          #
          def create_folder(path)
            fullpath = File.join(self.target_path, path)
            unless File.exists?(fullpath)
              FileUtils.mkdir_p(fullpath)
            end
          end

          # Open a file described by the relative path. The file will be closed after the execution of the block.
          #
          # @param [ String ] path The relative path
          # @param [ String ] mode The file mode ('w' by default)
          # @param [ Lambda ] &block The block passed to the File.open method
          #
          def open_file(path, mode = 'w', &block)
            # make sure the target folder exists
            self.create_folder(File.dirname(path))

            fullpath = File.join(self.target_path, path)

            File.open(fullpath, mode, &block)
          end

          def target_path
            self.runner.target_path
          end

          protected

          def resource_message(resource)
            "    writing #{truncate(resource.to_s)}"
          end

        end

      end
    end
  end
end