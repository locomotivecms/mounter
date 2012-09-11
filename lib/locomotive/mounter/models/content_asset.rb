module Locomotive
  module Mounter
    module Models

      class ContentAsset < Base

        ## fields ##
        field :source

        ## other accessors ##
        attr_accessor :folder, :filepath, :uri

        ## methods ##

        # Name of the file
        #
        # @return [ String ] Name of the file
        #
        def filename
          return @filename if @filename

          if self.uri
            @filename = File.basename(self.uri.path)
          else
            @filename = File.basename(self.filepath)
          end
        end

        # Content of the asset.
        #
        # @return [ String ] The content of the asset
        #
        def content
          return @raw if @raw

          if self.uri
            @raw = Net::HTTP.get(self.uri)
          else
            @raw = File.read(self.filepath)
          end
        end

        def local_filepath
          File.join('/', self.folder, self.filename)
        end

        def to_s
          self.uri ? self.uri.path : self.filepath
        end

      end

    end
  end
end