module Locomotive
  module Mounter
    module Models

      class ThemeAsset < Base

        PRECOMPILED_CSS_TYPES   = %w(sass scss less)

        PRECOMPILED_JS_TYPES    = %w(coffee)

        PRECOMPILED_FILE_TYPES  = PRECOMPILED_CSS_TYPES + PRECOMPILED_JS_TYPES

        ## fields ##
        field :folder

        ## other accessors ##
        attr_accessor :filepath, :uri, :size

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

        # Return the virtual path of the asset
        #
        # @return [ String ] The virtual path of the asset
        #
        def path
          File.join(self.folder, self.filename)
        end

        # Return the mime type of the file based on the Mime::Types lib.
        #
        # @return [ String ] The mime type of the file or nil if unknown.
        #
        def mime_type
          type = MIME::Types.type_for(self.filename)
          type.empty? ? nil : type.first
        end

        # Is the asset a stylesheet ?
        #
        # @return [ Boolean ] True if the filename ends with .css
        #
        def stylesheet?
          File.extname(self.filename) == '.css'
        end

        # Is the asset a javascript ?
        #
        # @return [ Boolean ] True if the filename ends with .js
        #
        def javascript?
          File.extname(self.filename) == '.js'
        end

        def stylesheet_or_javascript?
          self.stylesheet? || self.javascript?
        end

        # Give the priority of the asset depending of its type.
        # Javascripts and stylesheets are low priority.
        #
        # @return [ Integer ] The priority (0 -> high, 100 -> lower)
        #
        def priority
          self.stylesheet_or_javascript? ? 100 : 0
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

        # Return the params used for the API.
        #
        # @return [ Hash ] The params
        #
        def to_params
          { folder: self.folder }
        end

        def to_s
          self.path
        end

      end

    end
  end
end