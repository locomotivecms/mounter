module Locomotive
  module Mounter

    class Config < Hash

      # attr_accessor :implementations
      #
      # def initialize
      #   self.implementations = {}
      # end
      #
      # def self.instance
      #   @@instance ||= self.new
      # end
      #
      # def self.[](key)
      #
      # end

      def self.instance
        @@instance ||= self.new
      end

      def self.register(attributes)
        self.instance.merge!(attributes)
      end

      def self.[](key)
        self.instance[key]
      end

    end

  end
end