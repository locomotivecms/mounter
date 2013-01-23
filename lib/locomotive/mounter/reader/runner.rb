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
          self.parameters = parameters.symbolize_keys

          self.prepare

          self.build_mounting_point
        end

        # Reload with the same origin parameters a part of a site from a list of
        # resources each described by a simple name (site, pages, ...etc) taken from
        # the corresponding reader class name.
        #
        # @param [ Array/ String ] list An array of resource(s) or just the resource
        #
        def reload(*list)
          Locomotive::Mounter.with_locale(self.mounting_point.default_locale) do
            [*list].flatten.each do |name|
              reader_name = "#{name.to_s.camelize}Reader"

              reader = self.readers.detect do |_reader|
                _reader.name.demodulize == reader_name
              end

              if reader
                self.mounting_point.register_resource(name, reader.new(self).read)
              end
            end
          end
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
              name = reader.name.gsub(/(Reader)$/, '').demodulize.underscore

              self.mounting_point.register_resource(name, reader.new(self).read)
            end

            if self.respond_to?(:path)
              self.mounting_point.path = self.path
            end
          end
        end

      end

    end
  end
end