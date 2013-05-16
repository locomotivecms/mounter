require 'spec_helper'

describe Locomotive::Mounter::Writer::Api, :vcr do
  after(:all) do
    teardown
  end
  
  context "without console output" do
    before do
      setup "writer_api_setup"
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
      end

    end

    describe 'pages' do

      it 'creates all the pages' do
        Locomotive::Mounter::EngineApi.get('/pages.json').to_a.size.should == 14
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
    
    describe 'translations' do
      it 'creates all the translations' do
        Locomotive::Mounter::EngineApi.get('/translations.json').to_a.size.should == 1
      end
    end
    
  end
  
  context "with console output" do
    before do
      setup "writer_api_setup", true 
    end
    
    it "does not raise an exception due to a very long page title" do
      Locomotive::Mounter::EngineApi.get('/pages.json').map { |page| page['title'] }.should include("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo")
    end
  end
end