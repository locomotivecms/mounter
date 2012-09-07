module Locomotive
  module Mounter
    module Models

      class ThemeAsset < Base

        PRECOMPILED_FILE_TYPES = %w(sass scss coffee less)

        ## fields ##
        field :folder

        ## other accessors ##
        attr_accessor :filepath, :uri

        ## methods ##

        # Name of the file without any precompiled extensions (.sass, .scss, ...etc)
        #
        # @return [ String ] Name of the file
        #
        def filename
          return @filename if @filename

          if self.uri
            @filename = File.basename(self.uri.path)
          else
            regexps   = PRECOMPILED_FILE_TYPES.map { |ext| "\.#{ext}" }.join('|')

            @filename = File.basename(self.filepath).gsub(/#{regexps}/, '')
          end
        end

        # Tell if the asset can be precompiled. For instance, less, sass, scss and
        # coffeescript assets have to be precompiled.
        #
        # @return [ Boolean ] True if it has to be precompiled
        #
        def precompiled?
          @extname ||= File.extname(self.filepath)[1..-1]
          PRECOMPILED_FILE_TYPES.include?(@extname)
        end

        # Content of the asset. Pre-compile it if needed.
        #
        # @return [ String ] The content of the asset
        #
        def content
          return @raw if @raw

          if self.uri
            @raw = Net::HTTP.get(self.uri)
          elsif self.precompiled?
            template = Tilt.new(self.filepath)
            @raw = template.render
          else
            @raw = File.read(self.filepath)
          end
        end

      end

    end
  end
end