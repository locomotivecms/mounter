require 'spec_helper'

describe Locomotive::Mounter::Models::Page do

  it 'builds an empty page' do
    build_page.should_not be_nil
  end

  describe 'building a page from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_page(template: 'Hello world')
      }.should raise_exception
    end

    it 'sets a simple attribute' do
      build_page(handle: 'simple').handle.should == 'simple'
    end

    it 'sets a more complex attribute' do
      build_page(published: true).published.should be_true
    end

    it 'sets a localized attribute' do
      page = build_page(title: 'Hello world')
      page.localized?(:title).should be_true
      page.title.should == 'Hello world'
      I18n.with_locale(:fr) { page.title.should be_nil }

    end

    it 'sets a complete translation of a localized attribute' do
      page = build_page(title: { en: 'Hello world', fr: 'Salut le monde' })
      page.title.should == 'Hello world'
      I18n.with_locale(:fr) { page.title.should == 'Salut le monde' }
    end

  end

  describe 'translations' do

    it 'is translated in the current locale by default' do
      page = build_page(title: 'Hello world')
      page.translated_in.should == [:en]
    end

    it 'is translated in many different languages' do
      page = build_page(title: { en: 'Hello world', fr: 'Salut le monde', de: 'Hello Das Welt' })
      page.translated_in.should == [:en, :fr, :de]
    end

    it 'is translated if we use the direct attribute setter' do
      page = build_page(title: 'Hello world')
      I18n.with_locale(:fr) { page.title = 'Salut le monde' }
      page.translated_in.should == [:en, :fr]
    end

  end

  describe 'setting attributes' do

    before(:each) do
      @page = build_page
    end

    it 'sets a simple attribute' do
      @page.handle = 'test'
      @page.handle.should == 'test'
    end

    it 'sets a localized attribute' do
      @page.title = 'Hello world'
      @page.title.should == 'Hello world'
      @page.title_translations[:en].should == 'Hello world'
    end

  end

  describe 'depth' do

    before(:each) do
      @page = build_page
    end

    %w(index 404).each do |fullpath|
      it "is 0 for the '#{fullpath}' page" do
        @page.fullpath = fullpath
        @page.depth.should == 0
      end
    end

    it 'is 1 for the pages right under index' do
      @page.fullpath = 'contact_us'
      @page.depth.should == 1
    end

    it 'based on the number of sub levels' do
      @page.fullpath = 'about_us/team'
      @page.depth.should == 2

      @page.fullpath = 'about_us/index'
      @page.depth.should == 2

      @page.fullpath = 'about_us/team/john'
      @page.depth.should == 3
    end

  end

  describe 'slug' do

    before(:each) do
      @page = build_page
    end

    it 'can be retrieved' do
      @page.slug = 'hello-world'
      @page.slug.should == 'hello-world'
    end

    it 'takes the fullpath if it has not been set' do
      @page.fullpath = 'about-us/john-doe'
      @page.slug.should == 'john-doe'
    end

    it 'uses the localization' do
      @page.fullpath = 'about-us/john-doe'
      I18n.with_locale(:fr) do
        @page.fullpath = 'a-notre-sujet/jean-personne'
        @page.slug.should == 'jean-personne'
      end
      @page.slug.should == 'john-doe'
    end

  end

  describe 'adding child' do

    before(:each) do
      @page = build_page(:fullpath => 'index')
      @child = build_page(:title => 'Child')
      @page.add_child(@child)
    end

    it 'stores it' do
      @page.children.size.should == 1
      @page.children.first.title.should == 'Child'
    end

    it 'sets the parent of the child' do
      @child.parent.should == @page
    end

  end

  def build_page(attributes = {})
    Locomotive::Mounter::Models::Page.new(attributes)
  end

end
