require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  before(:each) do
    @path   = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
    @reader = Locomotive::Mounter::Reader::FileSystem.instance
  end

  it 'runs it' do
    @reader.stubs(:build_mounting_point).returns(true)
    @reader.run!(:path => @path).should_not be_nil
  end

  describe 'site' do

    before(:each) do
      stub_reader_builders(@reader)
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

  end # site

  describe 'pages' do

    before(:each) do
      stub_reader_builders(@reader, %w(pages))
      @mounting_point = @reader.run!(:path => @path)
      @index = @mounting_point.pages['index']
    end

    it 'has 11 pages' do
      @mounting_point.pages.size.should == 11
    end

    describe '#tree' do

      it 'puts pages under the index page' do
        @index.children.size.should == 5
      end

      it 'keeps the ordering of the config' do
        @index.children.map(&:fullpath).should == ['about-us', 'music', 'store', 'contact', 'events']
      end

      it 'also includes nested children' do
        @index.children.first.children.size.should == 2
        @index.children.first.children.map(&:fullpath).should == ['about-us/john-doe', 'about-us/jane-doe']
      end

      it 'localizes the fullpath' do
        Locomotive::Mounter.with_locale(:fr) do
          @index.children.first.children.map(&:fullpath).should == ['a-notre-sujet/jean-personne', 'a-notre-sujet/jane-doe']
        end
      end

    end

  end # pages

  describe 'snippets' do

    before(:each) do
      stub_reader_builders(@reader, %w(snippets))
      @mounting_point = @reader.run!(:path => @path)
    end

    it 'has 2 snippets' do
      @mounting_point.snippets.size.should == 2
      @mounting_point.snippets.keys.should == %w(song header)
      @mounting_point.snippets.values.map(&:slug).should == %w(song header)
    end

    it 'localizes the file path' do
      @mounting_point.snippets.values.first.template_filepath.should match /song\.liquid$/
      Locomotive::Mounter.with_locale(:fr) do
        @mounting_point.snippets.values.first.template_filepath.should match /song\.fr\.liquid\.haml$/
      end
    end

  end # snippets

  describe 'content types' do

    before(:each) do
      stub_reader_builders(@reader, %w(content_types))
      @mounting_point = @reader.run!(:path => @path)
    end

    it 'has 4 content types' do
      @mounting_point.content_types.size.should == 4
      @mounting_point.content_types.keys.should == %w(events messages songs updates)
      @mounting_point.content_types.values.map(&:slug).should == %w(events messages songs updates)
    end

    describe 'a single content type' do

      before(:each) do
        @content_type = @mounting_point.content_types.values.first
      end

      it 'has basic properties: name, slug' do
        @content_type.name.should == 'Events'
        @content_type.slug.should == 'events'
      end

      it 'has fields' do
        @content_type.fields.size.should == 4
        @content_type.fields.map(&:name).should == %w(place date city state)
        @content_type.fields.map(&:type).should == [:string, :date, :string, :string]
      end

    end

  end # content types

  describe 'content entries' do

    before(:each) do
      stub_reader_builders(@reader, %w(content_types content_entries))
      @mounting_point = @reader.run!(:path => @path)
    end

    it 'has 26 entries for the 4 content types' do
      @mounting_point.content_entries.size.should == 26
    end

    describe 'a single content entry' do

      before(:each) do
        @content_entry = @mounting_point.content_entries.values.first
      end

      it 'has a label' do
        @content_entry._label.should == "Avogadro's Number"
      end

      it 'has a slug' do
        @content_entry._slug.should == "avogadro-s-number"
      end

      it 'can access dynamic field' do
        @content_entry.city = 'Fort Collins'
      end

      it 'can access casted value of a dynamic field' do
        @content_entry.date = Date.parse('2012/06/11')
      end

    end

  end # content types

  def stub_reader_builders(reader, builders = nil)
    klasses = (builders ||= []).insert(0, 'site').map do |name|
      "Locomotive::Mounter::Reader::FileSystem::#{name.camelize}Builder".constantize
    end

    reader.stubs(:builders).returns(klasses)
  end

end