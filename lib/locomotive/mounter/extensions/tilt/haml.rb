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
      @data = @data.force_encoding('utf-8')
      begin
        super
      rescue Haml::SyntaxError => e
        # invalid haml so re-throw the exception but with keeping track of the attributes
        e.attributes = @attributes
        raise e
      end
    end

  end

  Tilt.register 'haml', YamlFrontMattersHamlTemplate
  Tilt.prefer YamlFrontMattersHamlTemplate

end

class ::Haml::SyntaxError
  attr_accessor :attributes
end