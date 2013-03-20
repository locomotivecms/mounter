require 'spec_helper'

describe Locomotive::Mounter::Writer::Api, :vcr do

  let(:reader) { Locomotive::Mounter::Reader::FileSystem.instance }

  let(:mounting_point) { reader.run!(path: site_path) }

  let(:writer) { Locomotive::Mounter::Writer::Api.instance }

  before(:all) do
    VCR.use_cassette "Writer::Api" do
      delete_current_site
      writer.run!({ mounting_point: mounting_point, console: false, data: true, force: false }.merge(credentials))
    end
  end

  describe 'site' do

    it 'has been created' do
      Locomotive::Mounter::EngineApi.get('/current_site.json').success?.should be_true
    end

  end

  describe 'content types' do

    it 'creates all the content types' do
      Locomotive::Mounter::EngineApi.get('/content_types.json').to_a.size.should == 5
    end

  end

  describe 'content entries' do

    it 'creates all the content entries' do
      Locomotive::Mounter::EngineApi.get('/content_types/events/entries.json').to_a.size.should == 12
      # Locomotive::Mounter::EngineApi.get('/content_types/products/entries.json').to_a.size.should == 1
    end

  end

  describe 'pages' do

    it 'creates all the pages' do
      Locomotive::Mounter::EngineApi.get('/pages.json').to_a.size.should == 13
    end

  end

  describe 'snippets' do

    it 'creates all the snippets' do
      Locomotive::Mounter::EngineApi.get('/snippets.json').to_a.size.should == 2
    end

  end

  describe 'theme assets' do

    it 'creates all the theme assets' do
      Locomotive::Mounter::EngineApi.get('/theme_assets.json').to_a.size.should == 16
    end

  end

end