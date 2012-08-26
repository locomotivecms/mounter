module Tilt

  # YAML Front-matters for HAML templates
  class YamlFrontMattersHamlTemplate < HamlTemplate

    # Attributes from YAML Front-matters header
    attr_reader :attributes

    def need_for_prerendering?
      true
    end

    def prepare
      if data =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
        @attributes = YAML.load($1)
        @data = $3
      end
      super
    end

  end

  Tilt.register 'haml', YamlFrontMattersHamlTemplate
  Tilt.prefer YamlFrontMattersHamlTemplate

end