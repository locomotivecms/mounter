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

            asset_paths(site_path).each do |asset_path|
              env.append_path asset_path
            end
          end
        end

        private

        def self.asset_paths site_path
          paths = Array.new
          %w(fonts stylesheets javascripts).each do |asset_type|
            rubygem_paths.each do |gem_path|
              gem_assets_path = File.join(gem_path, 'vendor/assets', asset_type)
              paths << gem_assets_path if File.directory?(gem_assets_path)
            end
            paths << File.join(site_path, 'public', asset_type)
          end
          return paths
        end

        def self.rubygem_paths
          ::Gem::Specification.latest_specs.map(&:full_gem_path)
        end

      end

    end
  end
end