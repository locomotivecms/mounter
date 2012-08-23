module Locomotive
  module Mounter
    module Models

      class Snippet < Base

        ## fields ##
        field :name
        field :slug
        field :template_filepath, localized: true

        ## methods ##

        # Return the Liquid template based on the template_filepath property
        # of the page. If the template is HAML, then a pre-rendering to Liquid is done.
        #
        # @return [ String ] The liquid template
        #
        def template
          case File.extname(self.template_filepath)
          when '.haml'    then Locomotive::Mounter::Utils::Haml.read(self.template_filepath)
          when '.liquid'  then File.read(self.template_filepath)
          else
            raise UnknownTemplateException.new("#{self.template_filapth} is not a valid template file")
          end
        end

      end

    end
  end
end