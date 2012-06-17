require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  before(:each) do
    @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
    @reader = Locomotive::Mounter::Reader::FileSystem.instance
  end

  it 'runs it' do
    @reader.run!(:path => @path).should_not be_nil
  end

  describe 'site' do

    before(:each) do
      @reader.stubs(:fetch_pages).returns(true)
      @mounting_point = @reader.run!(:path => @path)
    end

    it 'has a name' do
      @mounting_point.site.name.should == 'Sample website'
    end

    it 'has locales' do
      @mounting_point.site.locales.should == %w(en fr no)
    end

    it 'has a seo title' do
      @mounting_point.site.seo_title.should == 'A simple LocomotiveCMS website'
    end

    it 'has a meta keywords' do
      @mounting_point.site.meta_keywords.should == 'some meta keywords'
    end

    it 'has a meta description' do
      @mounting_point.site.meta_description.should == 'some meta description'
    end

  end

  describe 'page' do

    before(:each) do
      @mounting_point = @reader.run!(:path => @path)
    end

    it 'has 9 pages' do
      @mounting_point.pages.size.should == 9
    end

  end

end