module Locomotive
  module Mounter

    class MountingPoint

     attr_accessor :site, :root_page, :pages, :snippets

     ## methods ##

     def default_locale
       self.locales.first || I18n.locale
     end

     def locales
       self.site.locales || []
     end

     # def site=(site)
     #   @site = site
     #   @site.mounting_point = self
     # end

    end
  end
end