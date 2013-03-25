# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require 'rspec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'locomotive/mounter'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end

# require 'typhoeus/adapters/faraday'

# class Hash
#   def loop
#     self.each do |_, v|
#       if v.is_a?(String)
#         # do nothing
#       elsif v.is_a?(Hash)
#         v.loop
#       elsif v.is_a?(Array)
#         # puts v.inspect
#       end
#     end
#   end
# end

# require 'bson'
# require 'bson_ext'

# class MySerializer

#   # extend VCR::Cassette::EncodingErrorHandling

#   def file_extension
#     'binary'
#   end

#   def serialize(hash)
#     hash.loop
#     raise 'STOP'
#     Marshal.dump(hash).force_encoding("UTF-8")
#     # puts "deserialize = #{hash.keys.inspect}"
#     # puts Marshal.dump(hash).inspect

#     # hash.each { |k, v| }



#     # self.class.handle_encoding_errors do
#     #   # Marshal.dump(hash.encode!('ASCII-8BIT', 'UTF-8')) #.encode('UTF-8', 'ASCII-8BIT')
#     #   Marshal.dump(hash)
#     # end
#     # raise 'sTOP'
#     # "\xC8" from ASCII-8BIT to UTF-8
#   end

#   def deserialize(string)
#     Marshal.load(string)
#     # puts "deserialize = #{string}"
#     # Marshal.load(string.encode('UTF-8', 'ASCII-8BIT'))
#     # self.class.handle_encoding_errors do
#     #   Marshal.load(string)
#     # end
#   end

# end

# my_serializer = MySerializer.new

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  # c.hook_into :fakeweb
  c.hook_into :webmock
  # c.hook_into :faraday, :typhoeus
  # c.allow_http_connections_when_no_cassette = false # false -> strict
  c.configure_rspec_metadata!

  # c.query_parser = lambda { |query| raise query.inspect }
  # c.cassette_serializers[:my_custom_serializer] = my_serializer
  # c.default_cassette_options = { :serialize_with => :my_custom_serializer }
end





# conn = Faraday::Connection.new(:url => 'http://sample.example.com:4000') do |builder|
#   builder.use VCR::Middleware::Faraday do |cassette|
#     cassette.name    'faraday_example'
#     cassette.options :record => :new_episodes
#   end

#   builder.adapter :net_http
# end

# puts "Response 1: #{conn.get('/foo').body}"

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end