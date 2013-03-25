module Locomotive
  module Mounter
    module Models

      class Base

        include Locomotive::Mounter::Fields

        attr_accessor :_id, :mounting_point, :created_at, :updated_at

        ## methods ##

        def initialize(attributes = {})
          self.created_at = self.updated_at = Time.now
          self.mounting_point = attributes.delete(:mounting_point)
          super
        end

        def persisted?
        	!self._id.blank?
        end

        protected

        # Take a list of field names and return a hash with
        # their values only if they are not nil.
        #
        # @param [ Array ] fields List of field names (string)
        #
        # @return [ Hash ] A hash with symbolize keys
        #
        def filter_attributes(fields)
          self.attributes.clone.delete_if do |k, v|
            !fields.include?(k.to_s) || (!v.is_a?(FalseClass) && v.blank?)
          end.deep_symbolize_keys
        end

      end

    end
  end
end
