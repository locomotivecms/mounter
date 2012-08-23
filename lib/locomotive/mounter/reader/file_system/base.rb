module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class Base

         attr_accessor :runner, :items

         def initialize(runner)
           self.runner  = runner
           self.items   = {}
         end

         def mounting_point
           self.runner.mounting_point
         end

         def locales
           self.mounting_point.locales
         end

         protected

         # Return the locale of a file based on its extension.
         #
         # Ex: about_us/john_doe.fr.liquid.haml => 'fr'
         #
         # @param [ String ] filepath The path to the file
         #
         # @return [ String ] The locale (ex: fr, en, ...etc) or nil if it has no information about the locale
         #
         def filepath_locale(filepath)
           locale = File.basename(filepath).split('.')[1]

           locale && self.locales.include?(locale) ? locale : nil
         end

         # Open a YAML file and returns the content of the file
         #
         # @param [ String ] filepath The path to the file
         #
         # @return [ Object ] The content of the file
         #
         def read_yaml(filepath)
           YAML::load(File.open(filepath).read)
         end

       end

     end
   end
 end
end