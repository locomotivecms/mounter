require 'spec_helper'

describe Locomotive::Mounter::Writer::Api do

	before(:all) do
    @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
    @reader = Locomotive::Mounter::Reader::FileSystem.instance
    @mounting_point = @reader.run!(path: @path)
  end

  before(:each) do
    # @credentials  = { uri: 'sample.engine.dev/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' }
    @credentials  = { uri: 'test.example.com:8080/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' }
    @writer       = Locomotive::Mounter::Writer::Api.instance
  end

  it 'runs it' do
    @writer.run!({ mounting_point: @mounting_point }.merge(@credentials))
  end

end