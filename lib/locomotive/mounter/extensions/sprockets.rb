require 'yui/compressor'
require 'json'

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
        # @param [ Boolean ] minify Minify the js and css assets (default: false)
        #
        def self.environment(site_path, minify = false)
          return @@env if @@env && @@path == site_path

          @@path  = site_path
          @@env   = ::Sprockets::Environment.new.tap do |env|
            if minify && is_java_installed?
              # minify javascripts and stylesheets
              env.js_compressor  = YUI::JavaScriptCompressor.new
              env.css_compressor = YUI::CssCompressor.new
            else
              message = "[Important] YUICompressor requires java to be installed. The JAVA_HOME variable should also be set.\n"
              Locomotive::Mounter.logger.warn message.colorize(color: :red)
            end

            %w(fonts stylesheets javascripts).each do |name|
              env.append_path File.join(site_path, 'public', name)
            end

            bower_folder = File.join site_path, "bower_components"
            env.append_path bower_folder if File.directory? bower_folder
          end
        end

        def self.is_java_installed?
          `which java` != '' && (!ENV['JAVA_HOME'].blank? && File.exists?(ENV['JAVA_HOME']))
        end

      end

    end
  end
end
