module Locomotive
  module Mounter
    module Extensions

      module Compass

        # Configure Compass for the current site
        #
        # @param [ String ] site_path The root directory of the site
        #
        def self.configure(site_path)
          ::Compass.configuration do |config|
            config.project_path     = File.join(site_path, 'public')
            config.http_path        = '/'
            config.css_dir          = '../tmp/stylesheets'
            config.sass_dir         = 'stylesheets'
            config.fonts_dir        = 'fonts'
            config.images_dir       = 'images'
            config.javascripts_dir  = 'javascripts'
            config.project_type     = :stand_alone
            config.output_style     = :nested
            config.line_comments    = false
          end
        end

        # # Return the Compass options
        # #
        # # @return [ Hash ] The Compass options
        # def self.options
        #   ::Compass.configuration.to_sass_engine_options
        # end

      end

    end
  end
end