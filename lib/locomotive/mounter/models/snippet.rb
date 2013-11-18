module Locomotive
  module Mounter
    module Models

      class Snippet < Base

        ## fields ##
        field :name
        field :slug

        field :template, localized: true

        ## methods ##

        # Return the Liquid template based on the template_filepath property
        # of the snippet. If the template is HAML, then a pre-rendering to Liquid is done.
        #
        # @return [ String ] The liquid template
        #
        def source
          @source ||= {}

          source = if self.template.respond_to?(:source)
            # liquid or haml file
            self.template.source
          else
            # simple string
            self.template
          end

          @source[Locomotive::Mounter.locale] = source
        end

        # Return the params used for the API.
        #
        # @return [ Hash ] The params
        #
        def to_params
          params = self.filter_attributes %w(name slug)

          # raw_template
          params[:template] = self.source rescue nil

          params
        end

        def to_s
          self.name
        end

      end

    end
  end
end