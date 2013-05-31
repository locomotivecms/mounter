# encoding: UTF-8
require 'spec_helper'

describe Locomotive::Mounter::Reader::Api, :vcr do

  before(:all) do
    setup "reader_api_setup"
  end

  after(:all) do
    teardown
  end

  before(:each) do
    @reader       = Locomotive::Mounter::Reader::Api.instance
  end

  it 'runs it' do
    @reader.stubs(:prepare).returns(true)
    @reader.stubs(:build_mounting_point).returns(true)
    @reader.run!(credentials).should_not be_nil
  end

  describe 'site' do

    before(:each) do
      stub_readers(@reader)
      @mounting_point = @reader.run!(credentials)
    end

    it 'has a name' do
      @mounting_point.site.name.should == 'Sample website'
    end

    it 'has locales' do
      @mounting_point.site.locales.should == %w(en fr nb)
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

    it 'has timestamps' do
      @mounting_point.site.created_at.should_not be_nil
      @mounting_point.site.updated_at.should_not be_nil
    end

  end # site

  describe 'content_assets, content_types and pages' do

    before(:each) do
      stub_readers(@reader, %w(content_assets content_types pages))
      @mounting_point = @reader.run!(credentials)
    end

    describe 'pages' do

      before(:each) do
        @index          = @mounting_point.pages['index']
        @song_template  = @mounting_point.pages['songs/content_type_template']
      end

      it 'has 13 pages' do
        @mounting_point.pages.size.should == 14
      end

      describe '#tree' do

        it 'puts pages under the index page' do
          @index.children.size.should == 8
        end

        it 'keeps the ordering of the config' do
          @index.children.map(&:fullpath).should == ['about-us', 'music', 'store', 'contact', 'events', 'songs', 'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-do-eiusmod-tempor-incididunt-ut-labore-et-dolore-magna-aliqua', 'archives']
        end

        it 'assigns titles for all the pages' do
          @index.children.map(&:title).should == ['About Us', 'Music', 'Store', 'Contact Us', 'Events', 'Songs', 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo', 'Archives']
        end

        it 'also includes nested children' do
          page = @mounting_point.pages['about-us']
          page.children.size.should == 2
          page.children.map(&:fullpath).should == ['about-us/john-doe', 'about-us/jane-doe']
        end

        it 'localizes the fullpath' do
          page = @mounting_point.pages['about-us']
          Locomotive::Mounter.with_locale(:fr) do
            page.children.map(&:fullpath).should == ['a-notre-sujet/jean-personne', nil]
          end
        end

        it 'localizes titles' do
          Locomotive::Mounter.with_locale(:fr) do
            @index.children.map(&:title).should == ['A notre sujet', nil, 'Magasin', nil, nil, nil, nil, nil]
          end
        end

      end

      describe '#content_type' do

        it 'assigns it' do
          @song_template.content_type.should_not be_nil
          @song_template.content_type.slug.should == 'songs'
        end

      end

    end # pages

    describe 'content types' do

      it 'has 5 content types' do
        @mounting_point.content_types.size.should == 5
        @mounting_point.content_types.keys.should == %w(bands events messages songs updates)
        @mounting_point.content_types.values.map(&:slug).should == %w(bands events messages songs updates)
      end

      describe 'a single content type' do

        before(:each) do
          @content_type = @mounting_point.content_types['events']
        end

        it 'has basic properties: name, slug' do
          @content_type.name.should == 'Events'
          @content_type.slug.should == 'events'
        end

        it 'has fields' do
          @content_type.fields.size.should == 5
          @content_type.fields.map(&:name).should == %w(place date city state notes)
          @content_type.fields.map(&:type).should == [:string, :date, :string, :string, :text]
        end

      end

    end # content types

    describe 'content assets' do

      it 'has 3 assets' do
        @mounting_point.content_assets.size.should == 3
      end

    end # content assets

  end

  describe 'snippets' do

    before(:each) do
      stub_readers(@reader, %w(snippets))
      @mounting_point = @reader.run!(credentials)
    end

    it 'has 2 snippets' do
      @mounting_point.snippets.size.should == 2
      @mounting_point.snippets.keys.sort.should == %w(header song)
      @mounting_point.snippets.values.map(&:slug).sort.should == %w(header song)
    end

    it 'localizes the template' do
      @mounting_point.snippets['song'].source.should match /&rarr; Listen/
      Locomotive::Mounter.with_locale(:fr) do
        @mounting_point.snippets['song'].source.should match /&rarr; écouter/
      end
    end

  end # snippets

  describe 'content entries' do

    before(:each) do
      stub_readers(@reader, %w(content_assets content_types content_entries))
      @mounting_point = @reader.run!(credentials)
    end

    it 'has 29 entries for the 4 content types' do
      @mounting_point.content_entries.size.should == 29
    end

    describe 'a single content entry' do

      before(:each) do
        content_type    = @mounting_point.content_types['events']
        @content_entry  = content_type.entries.first
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

      it 'has a text' do
        @content_entry.notes.should match /<p>Lorem ipsum<img src="\/samples\/assets\/.*" alt="" \/><\/p>/
      end

      it 'has timestamps' do
        @content_entry.created_at.should_not be_nil
        @content_entry.updated_at.should_not be_nil
      end

    end

  end # content entries

  describe 'theme assets' do

    before(:each) do
      stub_readers(@reader, %w(theme_assets))
      @mounting_point = @reader.run!(credentials)
    end

    it 'has 16 assets' do
      @mounting_point.theme_assets.size.should == 16
    end

  end # theme assets

  def stub_readers(reader, readers = nil)
    klasses = (readers ||= []).insert(0, 'site').uniq.map do |name|
      "Locomotive::Mounter::Reader::Api::#{name.camelize}Reader".constantize
    end

    reader.stubs(:readers).returns(klasses)
  end

end