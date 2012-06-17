module Locomotive
  module Mounter
    module Reader
     module FileSystem

       class Base

         attr_accessor :runner

         def initialize(runner)
           self.runner = runner
         end

         def config
           self.runner.config
         end

         def mounting_point
           self.runner.mounting_point
         end

         def locales
           self.mounting_point.locales
         end

       end

     end
   end
 end
end