module Locomotive
  module Mounter
    module Reader
      module Api

        class SiteReader < Base

          def read
            # get the site from the API
            site = self.get(:current_site)

            # set the default locale first
            Locomotive::Mounter.locale = site['locales'].first.to_sym

            Locomotive::Mounter::Models::Site.new(site).tap do |site|
              # fetch the information in other locales
              site.locales[1..-1].each do |locale|
                Locomotive::Mounter.with_locale(locale) do
                  self.get(:current_site, locale).each do |name, value|
                    next unless %w(seo_title meta_keywords meta_description).include?(name)
                    site.send(:"#{name}=", value)
                  end
                end
              end
            end
          end

          def safe_attributes
            %w(name locales seo_title meta_keywords meta_description domains subdomain created_at updated_at)
          end

        end

      end
    end
  end
end
