module Locomotive
  module Mounter
    module Reader

     class Runner

       attr_accessor :kind, :parameters, :mounting_point

       def initialize(kind)
         self.kind = kind

         # avoid to load all the ruby files at the startup, only when we need it
         base_dir = File.join(File.dirname(__FILE__), kind.to_s)
         require File.join(base_dir, 'base.rb')
         Dir[File.join(base_dir, '*.rb')].each { |lib| require lib }
       end

       # Read the content of a site (pages, snippets, ...etc) and create the corresponding mounting point.
       #
       # @param [ Hash ] parameters The parameters.
       #
       # @return [ Object ] The mounting point object storing all the information about the site
       #
       def run!(parameters = {})
         self.parameters = parameters

         self.prepare

         self.build_mounting_point
       end

       # Before building the mounting point.
       # Can be defined by reader runners
       def prepare
       end

       # Ordered list of atomic readers
       #
       # @return [ Array ] List of classes
       #
       def readers
         raise Locomotive::Mounter::ImplementationIsMissingException.new('readers are missing')
       end

       protected

       def build_mounting_point
         Locomotive::Mounter::MountingPoint.new.tap do |mounting_point|
           self.mounting_point = mounting_point

           self.readers.each do |reader|
             puts "READER #{reader.inspect}"
             name = reader.name.gsub(/(Reader)$/, '').demodulize.underscore

             self.mounting_point.register_resource(name, reader.new(self).read)
           end
         end
       end

     end

    end
  end
end