module Locomotive
  module Mounter
    module Reader
     module Api

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

         def get(resource_name, locale = nil, raw = false)
           params = { query: {} }

           params[:query][:locale] = locale if locale

           response = Locomotive::Mounter::EngineApi.get("/#{resource_name}.json", params).parsed_response

           return response if raw

           case response
           when Hash then response.to_hash.delete_if { |k, _| !self.safe_attributes.include?(k) }
           when Array
             response.map do |row|
               # puts "#{row.inspect}\n---" # DEBUG
               row.delete_if { |k, _| !self.safe_attributes.include?(k) }
             end
           else
             response
           end
         end

       end

     end
   end
 end
end