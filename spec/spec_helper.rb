require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require 'rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'locomotive/mounter'

RSpec.configure do |config|
  config.mock_with :mocha
end
