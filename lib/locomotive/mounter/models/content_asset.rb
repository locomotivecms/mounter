module Locomotive
  module Mounter
    module Models

      class ContentAsset < Base

        ## fields ##
        field :filepath
        field :folder

        ## methods ##

        # Name of the file
        def filename
          File.basename(self.filepath)
        end

        # Content of the asset.
        #
        # @return [ String ] The content of the asset
        #
        def content
          @content ||= File.read(self.filepath)
        end

        def to_s
          File.join(self.folder, self.filename)
        end

      end

    end
  end
end