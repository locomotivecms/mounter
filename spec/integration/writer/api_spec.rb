require 'spec_helper'

describe Locomotive::Mounter::Writer::Api do

	before(:all) do
    @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
    @reader = Locomotive::Mounter::Reader::FileSystem.instance
    @mounting_point = @reader.run!(path: @path)
  end

  before(:each) do
    # @credentials  = { uri: 'sample.engine.dev/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' }
    @credentials  = { uri: 'test.engine.dev:8080/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' }
    delete_current_site
    @writer       = Locomotive::Mounter::Writer::Api.instance
  end

  describe 'site' do

    before(:each) do
      stub_writers(@writer)
      @writer.run!({ mounting_point: @mounting_point }.merge(@credentials))
    end

    it 'has been created' do
      Locomotive::Mounter::EngineApi.get('/current_site.json').success?.should be_true
    end

  end

  describe 'pages' do

    before(:each) do
      stub_writers(@writer, %w(pages))
      @writer.run!({ mounting_point: @mounting_point, console: true }.merge(@credentials))
    end

    it 'creates all the pages' do
      # Locomotive::Mounter::EngineApi.get('/pages.json').to_a.size.should == 11
    end

  end

  def delete_current_site
    Locomotive::Mounter::EngineApi.set_token @credentials[:uri], @credentials[:email], @credentials[:password]
    Locomotive::Mounter::EngineApi.delete('/current_site.json')
  end

  def stub_writers(writer, writers = nil)
    klasses = (writers ||= []).insert(0, 'site').uniq.map do |name|
      "Locomotive::Mounter::Writer::Api::#{name.camelize}Writer".constantize
    end

    writer.stubs(:writers).returns(klasses)
  end

end