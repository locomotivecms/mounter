module Locomotive
  module Mounter

    class DefaultException < ::Exception

      def initialize(message = nil)
        Locomotive::Mounter.logger.warn message
        super
      end

    end

    class FieldDoesNotExistException < DefaultException
    end

    class UnknownContentTypeException < DefaultException
    end

    class DuplicateContentEntryException < DefaultException
    end

    class UnknownTemplateException < DefaultException
    end

  end
end
