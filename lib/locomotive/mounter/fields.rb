module Locomotive
  module Mounter

    module Field

      included do

        extend ActiveSupport::Concern

      end

      def localized?(name)
        self.send :"#{name}_localized?"
      end

      # def translations_for(name)
      #   self.send :"#{name}_translations"
      # end

      module ClassMethods

        def field(name, options = {})
          options = { localized: false }.merge(options)

          class_eval <<-EOV
            def #{name}
              self.getter '#{name}', #{options[:localized]}
            end

            def #{name}=(value)
              self.getter '#{name}', value, #{options[:localized]}
            end

            def #{name}_localized?
              #{options[:localized]}
            end
          EOV

          if options[:localized]
            class_eval <<-EOV
              def #{name}_translations
                @#{name} || {}
              end

              def #{name}_translations=(translations)
                @#{name} = translations
              end
            EOV
          end
        end

        protected

        def getter(name, localized = false)
          value = self.instance_variable_get(name.to_sym)
          if localized
            (value || {})[I18n.locale]
          else
            value
          end
        end

        def setter(name, value, localized = false)
          if localized
            translations = self.instance_variable_get(name.to_sym) || {}
            translations[I18n.locale] = value
            value = translations
          end
          self.instance_variable_set(name.to_sym, value)
        end

      end

    end
  end
end