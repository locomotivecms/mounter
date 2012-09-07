require 'spec_helper'

describe Locomotive::Mounter::Models::ThemeAsset do

  it 'builds an empty theme asset' do
    build_theme_asset.should_not be_nil
  end

  describe 'building a theme_asset from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_theme_asset(url: 'Hello world')
      }.should raise_exception
    end

    it 'sets a simple attribute' do
      build_theme_asset(folder: 'foo/bar').folder.should == 'foo/bar'
    end

  end

  describe 'setting attributes' do

    before(:each) do
      @theme_asset = build_theme_asset
    end

    it 'sets a simple attribute' do
      @theme_asset.folder = 'foo/bar'
      @theme_asset.folder.should == 'foo/bar'
    end

  end

  describe '#filename' do

    it 'retrieves it from the filepath' do
      build_theme_asset(filepath: '/tmp/foo.css').filename.should == 'foo.css'
    end

    it 'removes extensions' do
      build_theme_asset(filepath: '/tmp/foo.css.scss').filename.should == 'foo.css'
    end

    it 'retrieves it from the uri' do
      build_theme_asset(uri: URI('http://example.com/tmp/bar.css')).filename.should == 'bar.css'
    end

  end

  def build_theme_asset(attributes = {})
    Locomotive::Mounter::Models::ThemeAsset.new(attributes)
  end

end
