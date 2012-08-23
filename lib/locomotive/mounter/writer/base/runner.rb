module Locomotive
  module Mounter
    module Writer
      module Base

        class Runner

          attr_accessor :target_path, :mounting_point

          # Read / parse the content of a folder and build
          # all the related data of the site.
          #
          # @param [ Hash ] parameters The parameters. It should contain the mounting_point and target_path keys.
          #
          # @return [ Object ] The mounting point object storing all the information about the site
          #
          def run!(parameters = {})
            puts "[Writer::Base] yeaah ! #{parameters.keys.inspect}"

            self.mounting_point = parameters[:mounting_point]
            self.target_path    = parameters[:target_path]

            return nil if self.target_path.blank? || self.mounting_point.nil?

            self.write_all

            self.target_path
            # TODO
            # first the site
          end

          def write_all
            self.writers.each do |klass|
              klass.new(self.mounting_point, self.target_path).write
            end
          end

          def writers
            []
          end

        end

      end
    end
  end
end