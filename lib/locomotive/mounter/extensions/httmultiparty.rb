# Patch for https://github.com/jwagener/httmultiparty/issues/11

module HTTMultiParty
  module ClassMethods

    private

      def perform_request(http_method, path, options, &block) #:nodoc:
        options = default_options.dup.merge(options)

        # FIXME: default_params are not handled for some unknown reasons, so move them to the body instead
        if http_method == MultipartPost || http_method == MultipartPut
          default_params = options.delete(:default_params)
          options[:body].merge!(default_params) if options[:body] && default_params
        end

        process_cookies(options)
        HTTParty::Request.new(http_method, path, options).perform(&block)
      end

  end
end