require 'webmock'
require 'httmultiparty'
require 'tempfile'

class FakeUploadIO

  attr_accessor :original_filename, :content_type, :body

  def initialize(io)
    io.rewind # make sure....

    self.original_filename  = io.original_filename || File.basename(io.local_path)
    self.content_type       = io.content_type
    self.body               = io.read

    io.rewind # ...we don't mess up with the io
  end

  # FIXME: not used
  def to_io
    file = Tempfile.new(self.original_filename)
    file.write(self.body)
    UploadIO.new(file, self.content_type)
  end

end

module WebMock
  module NetHTTPUtility

    def self.request_signature_from_request(net_http, request, body = nil)
      protocol = net_http.use_ssl? ? "https" : "http"

      path = request.path
      path = WebMock::Util::URI.heuristic_parse(request.path).request_uri if request.path =~ /^http/

      if request["authorization"] =~ /^Basic /
        userinfo = WebMock::Util::Headers.decode_userinfo_from_header(request["authorization"])
        userinfo = WebMock::Util::URI.encode_unsafe_chars_in_userinfo(userinfo) + "@"
      else
        userinfo = ""
      end

      uri = "#{protocol}://#{userinfo}#{net_http.address}:#{net_http.port}#{path}"
      method = request.method.downcase.to_sym

      headers = Hash[*request.to_hash.map {|k,v| [k, v]}.inject([]) {|r,x| r + x}]

      headers.reject! {|k,v| k =~ /[Aa]uthorization/ && v.first =~ /^Basic / } #we added it to url userinfo

      if body != nil && body.respond_to?(:read)
        request.set_body_internal body.read
      else
        request.set_body_internal body
      end

     _body = request.respond_to?(:body_footprint) ? request.body_footprint : request.body

      WebMock::RequestSignature.new(method, uri, :body => _body, :headers => headers)
    end
  end
end

module HTTMultiParty::Multipartable::Webmock

  def body_footprint
    return self.body if @_body.blank?

    Marshal.dump(@_body.map do |key, _value|
      _value = FakeUploadIO.new(_value) if _value.is_a?(UploadIO)
      [key, _value]
    end)
  end

  def body=(value)
    if value.is_a?(Array)
      @_body = value.dup # save it for later
      super(value)
    else
      # does this case exist for real ? Never observed so far
      puts "[httmultiparty] not an array !!! #{value.class}."
      raise 'STOP'
    end
  end
end

class HTTMultiParty::MultipartPost < Net::HTTP::Post
  include HTTMultiParty::Multipartable::Webmock
end
