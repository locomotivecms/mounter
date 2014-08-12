require 'yui/compressor'

module Locomotive
  module Mounter
    module Extensions

      module Sprockets

        @@env = @@path = nil

        # Build a Sprocket environment for the current site.
        # This method returns an unique environment for each call
        # unless the site_path changed.
        #
        # @param [ String ] site_path The root directory of the site
        #
        def self.environment(site_path)
          return @@env if @@env && @@path == site_path

          @@path  = site_path
          @@env   = ::Sprockets::Environment.new.tap do |env|
            # minify javascripts and stylesheets
            env.js_compressor  = YUI::JavaScriptCompressor.new
            env.css_compressor = YUI::CssCompressor.new

            %w(fonts stylesheets javascripts).each do |name|
              env.append_path File.join(site_path, 'public', name)
            end
          end
        end

      end

    end
  end
end