# encoding: UTF-8
require 'spec_helper'

describe Locomotive::Mounter::Reader::Api do

  before(:each) do
    @credentials  = { uri: 'sample.engine.dev/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' }
    @reader       = Locomotive::Mounter::Reader::Api.instance
  end

  it 'runs it' do
    @reader.stubs(:prepare).returns(true)
    @reader.stubs(:build_mounting_point).returns(true)
    @reader.run!(@credentials).should_not be_nil
  end

  %w(uri email password).each do |name|
    it "requires #{name} in the credentials" do
      Locomotive::Mounter::EngineApi.stubs(:set_token).returns(true)
      @reader.stubs(:build_mounting_point).returns(true)
      lambda {
        @credentials.delete(name.to_sym)
        @reader.run!(@credentials)
      }.should raise_exception(Locomotive::Mounter::ReaderException, 'one or many API credentials (uri, email, password) are missing')
    end
  end

  describe 'site' do

    before(:each) do
      stub_readers(@reader)
      @mounting_point = @reader.run!(@credentials)
    end

    it 'has a name' do
      @mounting_point.site.name.should == 'Sample website'
    end

    it 'has locales' do
      @mounting_point.site.locales.should == %w(en fr)
    end

    it 'has a seo title' do
      @mounting_point.site.seo_title.should == 'A simple LocomotiveCMS website'
    end

    it 'also has a seo title in French' do
      Locomotive::Mounter.with_locale(:fr) do
        @mounting_point.site.seo_title.should == 'Un simple LocomotiveCMS site web'
      end
    end

    it 'has a meta keywords' do
      @mounting_point.site.meta_keywords.should == 'some meta keywords'
    end

    it 'has a meta description' do
      @mounting_point.site.meta_description.should == 'some meta description'
    end

  end # site

  # describe 'pages' do
  #
  #   before(:each) do
  #     stub_reader_builders(@reader, %w(pages))
  #     @mounting_point = @reader.run!(:path => @path)
  #     @index = @mounting_point.pages['index']
  #   end
  #
  #   it 'has 11 pages' do
  #     @mounting_point.pages.size.should == 11
  #   end
  #
  #   describe '#tree' do
  #
  #     it 'puts pages under the index page' do
  #       @index.children.size.should == 6
  #     end
  #
  #     it 'keeps the ordering of the config' do
  #       @index.children.map(&:fullpath).should == ['about-us', 'music', 'store', 'contact', 'events', 'archives']
  #     end
  #
  #     it 'assigns titles for all the pages' do
  #       @index.children.map(&:title).should == ['About Us', 'Music', 'Store', 'Contact Us', 'Events', 'Archives']
  #     end
  #
  #     it 'also includes nested children' do
  #       @index.children.first.children.size.should == 2
  #       @index.children.first.children.map(&:fullpath).should == ['about-us/john-doe', 'about-us/jane-doe']
  #     end
  #
  #     it 'localizes the fullpath' do
  #       Locomotive::Mounter.with_locale(:fr) do
  #         @index.children.first.children.map(&:fullpath).should == ['a-notre-sujet/jean-personne', 'a-notre-sujet/jane-doe']
  #       end
  #     end
  #
  #     it 'localizes titles' do
  #       Locomotive::Mounter.with_locale(:fr) do
  #         @index.children.map(&:title).should == ['A notre sujet', nil, 'Magasin', nil, nil, nil]
  #       end
  #     end
  #
  #
  #   end
  #
  # end # pages
  #
  # describe 'snippets' do
  #
  #   before(:each) do
  #     stub_reader_builders(@reader, %w(snippets))
  #     @mounting_point = @reader.run!(:path => @path)
  #   end
  #
  #   it 'has 2 snippets' do
  #     @mounting_point.snippets.size.should == 2
  #     @mounting_point.snippets.keys.should == %w(song header)
  #     @mounting_point.snippets.values.map(&:slug).should == %w(song header)
  #   end
  #
  #   it 'localizes the template' do
  #     @mounting_point.snippets.values.first.source.should match /&rarr; Listen/
  #     Locomotive::Mounter.with_locale(:fr) do
  #       @mounting_point.snippets.values.first.source.should match /&rarr; écouter/
  #     end
  #   end
  #
  # end # snippets
  #
  # describe 'content types' do
  #
  #   before(:each) do
  #     stub_reader_builders(@reader, %w(content_types))
  #     @mounting_point = @reader.run!(:path => @path)
  #   end
  #
  #   it 'has 4 content types' do
  #     @mounting_point.content_types.size.should == 4
  #     @mounting_point.content_types.keys.should == %w(events messages songs updates)
  #     @mounting_point.content_types.values.map(&:slug).should == %w(events messages songs updates)
  #   end
  #
  #   describe 'a single content type' do
  #
  #     before(:each) do
  #       @content_type = @mounting_point.content_types.values.first
  #     end
  #
  #     it 'has basic properties: name, slug' do
  #       @content_type.name.should == 'Events'
  #       @content_type.slug.should == 'events'
  #     end
  #
  #     it 'has fields' do
  #       @content_type.fields.size.should == 4
  #       @content_type.fields.map(&:name).should == %w(place date city state)
  #       @content_type.fields.map(&:type).should == [:string, :date, :string, :string]
  #     end
  #
  #   end
  #
  # end # content types
  #
  # describe 'content entries' do
  #
  #   before(:each) do
  #     stub_reader_builders(@reader, %w(content_types content_entries))
  #     @mounting_point = @reader.run!(:path => @path)
  #   end
  #
  #   it 'has 26 entries for the 4 content types' do
  #     @mounting_point.content_entries.size.should == 26
  #   end
  #
  #   describe 'a single content entry' do
  #
  #     before(:each) do
  #       @content_entry = @mounting_point.content_entries.values.first
  #     end
  #
  #     it 'has a label' do
  #       @content_entry._label.should == "Avogadro's Number"
  #     end
  #
  #     it 'has a slug' do
  #       @content_entry._slug.should == "avogadro-s-number"
  #     end
  #
  #     it 'can access dynamic field' do
  #       @content_entry.city = 'Fort Collins'
  #     end
  #
  #     it 'can access casted value of a dynamic field' do
  #       @content_entry.date = Date.parse('2012/06/11')
  #     end
  #
  #   end
  #
  # end # content types

  def stub_readers(reader, readers = nil)
    klasses = (builders ||= []).insert(0, 'site').map do |name|
      "Locomotive::Mounter::Reader::Api::#{name.camelize}Reader".constantize
    end

    reader.stubs(:readers).returns(klasses)
  end

end