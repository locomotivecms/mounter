module Locomotive
  module Mounter
    module Utils

      module Haml

        # Read a HAML file and render it.
        #
        # @param [ String ] filepath The path to the file
        #
        # @param [ String ] The rendered HAML file.
        def self.read(filepath)
          return nil unless File.exists?(filepath)

          template = File.read(filepath).gsub(/---.*---/m, '')
          template = template.force_encoding('UTF-8') if RUBY_VERSION =~ /1\.9/

          engine = ::Haml::Engine.new(template)
          engine.render
        end

      end

    end
  end
end