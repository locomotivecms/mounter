module Locomotive
  module Mounter

    class DefaultException < ::Exception

      def initialize(message = nil)
        Locomotive::Mounter.logger.error message
        super
      end

    end

    class ReaderException < DefaultException
    end

    class WriterException < DefaultException
    end

    class ImplementationIsMissingException < DefaultException
    end

    class FieldDoesNotExistException < DefaultException
    end

    class UnknownContentTypeException < DefaultException
    end

    class DuplicateContentEntryException < DefaultException
    end

    class UnknownTemplateException < DefaultException
    end

    class WrongCredentials < DefaultException
    end

  end
end
