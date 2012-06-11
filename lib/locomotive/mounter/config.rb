module Locomotive
  module Mounter

    class Config < Hash

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