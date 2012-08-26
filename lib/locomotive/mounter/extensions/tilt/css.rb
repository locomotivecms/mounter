module Tilt

  # Sass with Compass features
  class SassWithCompassTemplate < SassTemplate

    private

    def sass_options
      super.merge(::Compass.configuration.to_sass_engine_options)
    end

  end

  Tilt.register 'sass', SassWithCompassTemplate
  Tilt.prefer SassWithCompassTemplate

  # Scss with Compass features
  class ScssWithCompassTemplate < ScssTemplate

    private

    def sass_options
      super.merge(::Compass.configuration.to_sass_engine_options)
    end

  end

  Tilt.register 'scss', ScssWithCompassTemplate
  Tilt.prefer ScssWithCompassTemplate

end