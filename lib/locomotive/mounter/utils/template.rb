module Locomotive
  module Mounter
    module Utils

      module Template

        # # Read a HAML / SLIM / Liquid file and precompile it into a
        # # Liquid file if necessary.
        # #
        # # @param [ Object ] content_or_file The raw content or a file descriptor
        # # @param [ Symbol ] type The type of the content
        # #
        # # @return [ String ] The corresponding liquid content
        # #
        # def self.precompile(content_or_file, type = nil)
        #   content = content_or_file
        #
        #   if content_or_file.respond_to?(:read)
        #     type    = File.extname(content_or_file)[1..-1].to_sym
        #     content = content_or_file.read
        #   end
        #
        #   case type.to_sym
        #   when :liquid  then content
        #   when :haml    then Tilt::HamlTemplate.new(content).render
        #   when :slim    then Tilt::SlimTemplate.new(content).render
        #   else
        #     raise UnknownTemplateException.new("#{type} is unknown")
        #   end
        # end


          # return nil unless File.exists?(filepath)
          #
          # if File.extname(filepath) == '.liquid'
          #   File.read(filepath).force_encoding('UTF-8').gsub(/---.*---/m, '')
          # else
          #   template = Tilt.new(filepath)
          #   template.render
          # end
            # # YAML Frontmatter ?
            # header = content.lines.enum_for(:each_with_index).select { |line,| line == "---\n" }

            # if header


          # case File.extname(self.template_filepath)
          # when PRECOMPILED_EXTENSIONS then Locomotive::Mounter::Utils::Template.read(self.template_filepath)
          # when '.liquid'              then File.read(self.template_filepath)
          # else
          #   raise UnknownTemplateException.new("#{self.template_filapth} is not a valid template file")
          # end

          # if filepath.
          #
          # template = File.read(filepath).gsub(/---.*---/m, '')
          # template = template.force_encoding('UTF-8') if RUBY_VERSION =~ /1\.9/
          #
          # engine = ::Haml::Engine.new(template)
          # engine.render
        # end

      end

    end
  end
end