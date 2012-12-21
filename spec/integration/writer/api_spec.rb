require 'spec_helper'

describe Locomotive::Mounter::Writer::Api do

  let(:site_path) { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'simple') }

  let(:credentials) { { uri: 'sample.example.com:8080/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' } }

  let(:reader) { Locomotive::Mounter::Reader::FileSystem.instance }

  let(:mounting_point) { reader.run!(path: site_path) }

  let(:writer) { Locomotive::Mounter::Writer::Api.instance }

  before(:all) do
    delete_current_site
    writer.run!({ mounting_point: mounting_point, console: true, force: false }.merge(credentials))
  end

  # describe 'site' do

  #   it 'has been created' do
  #     Locomotive::Mounter::EngineApi.get('/current_site.json').success?.should be_true
  #   end

  # end

  # describe 'content types' do

  #   it 'creates all the content types' do
  #     Locomotive::Mounter::EngineApi.get('/content_types.json').to_a.size.should == 5
  #   end

  # end

  describe 'content entries' do

    it 'creates all the content entries' do
      # Locomotive::Mounter::EngineApi.get('/content_types/events/entries.json').to_a.size.should == 12
      Locomotive::Mounter::EngineApi.get('/content_types/products/entries.json').to_a.size.should == 1
    end

  end

  # describe 'pages' do

  #   it 'creates all the pages' do
  #     Locomotive::Mounter::EngineApi.get('/pages.json').to_a.size.should == 13
  #   end

  # end

  # describe 'snippets' do

  #   it 'creates all the snippets' do
  #     Locomotive::Mounter::EngineApi.get('/snippets.json').to_a.size.should == 2
  #   end

  # end

  # describe 'theme assets' do

  #   it 'creates all the theme assets' do
  #     Locomotive::Mounter::EngineApi.get('/theme_assets.json').to_a.size.should == 16
  #   end

  # end

  def delete_current_site
    Locomotive::Mounter::EngineApi.set_token credentials
    Locomotive::Mounter::EngineApi.delete('/current_site.json')
  end

end