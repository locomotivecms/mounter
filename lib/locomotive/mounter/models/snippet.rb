module Locomotive
  module Mounter
    module Models

      class Snippet < Base

        ## fields ##
        field :name
        field :slug

        # field :template_filepath, localized: true
        field :template, localized: true

        ## methods ##

        # Return the Liquid template based on the template_filepath property
        # of the snippet. If the template is HAML or SLIM, then a pre-rendering to Liquid is done.
        #
        # @return [ String ] The liquid template
        #
        def source
          @source ||= {}
          @source[Locomotive::Mounter.locale] ||= self.template.need_for_prerendering? ? self.template.render : self.template.data
        end

      end

    end
  end
end