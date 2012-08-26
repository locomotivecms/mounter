module Tilt

  # YAML Front-matters for Liquid templates
  class YamlFrontMattersLiquidTemplate < Template

    # Attributes from YAML Front-matters header
    attr_reader :attributes

    def prepare
      if data =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
        @attributes = YAML.load($1)
        @data = $3
      end
      # Note: do not call 'super' because we are going to use a different parse mechanism
    end

  end

  Tilt.register 'liquid', YamlFrontMattersLiquidTemplate
  Tilt.prefer YamlFrontMattersLiquidTemplate

end