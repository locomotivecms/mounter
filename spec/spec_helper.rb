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


require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  # c.allow_http_connections_when_no_cassette = false # false -> strict
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.filter_run focused: true
  c.run_all_when_everything_filtered = true

  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end