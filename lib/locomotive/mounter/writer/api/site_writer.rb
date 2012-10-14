module Locomotive
  module Mounter
    module Writer
      module Api

        class SiteWriter < Base

          attr_accessor :remote_site

          # Check if the site has to be created before.
          def prepare
            super

            if self.fetch_site.nil?
              Mounter.logger.warn 'The site does not exist. Trying to create it.'

              unless self.has_admin_rights?
                raise Mounter::WriterException.new('Your account does not own admin rights.')
              end
            else
              self.check_locales
            end
          end

          # Create the site if it does not exist
          def write
            unless self.site.persisted?
              # create it in the default locale
              Mounter.with_locale(self.default_locale) do
                self.output_locale

                if (site = self.post(:sites, self.site.to_hash(false), Mounter.locale)).nil?
                  raise Mounter::WriterException.new('Sorry, we are unable to create the site.')
                else
                  self.site._id = site['_id']
                end
              end

              # update it in other locales
              self.site.translated_in.each do |locale|
                next if locale.to_s == self.default_locale.to_s
                Mounter.with_locale(locale) do
                  self.output_locale
                  self.put(:sites, self.site._id, self.site.to_hash(false), Mounter.locale)
                end
              end
            end
          end

          protected

          def safe_attributes
            %w(_id locales)
          end

          def fetch_site
            self.get(:current_site).tap do |_site|
              if _site
                self.remote_site  = _site
                self.site._id     = _site['_id']
              end
            end
          end

          def check_locales
            default_locale  = self.mounting_point.default_locale
            locales         = self.site.locales
            remote_locales  = self.remote_site['locales']
            message         = nil

            unless locales.all? { |l| remote_locales.include?(l) }
              message = "Your site locales (#{locales.join(', ')}) do not match exactly the ones of your target (#{remote_locales.join(', ')})"
            end

            if default_locale != remote_locales.first
              message = "Your default site locale (#{default_locale}) is not the same as the one of your target (#{remote_locales.first})"
            end

            raise Mounter::WriterException.new(message) if message
          end

          def has_admin_rights?
            self.get(:my_account, nil, true)['admin']
          end

        end

      end
    end
  end
end