require 'spec_helper'

describe Locomotive::Mounter::Models::Page do

  it 'builds an empty page' do
    build_page.should_not be_nil
  end

  describe 'building a page from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_page(template_filepath: 'Hello world')
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
      page.localized_field?(:title).should be_true
      page.title.should eq 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { page.title.should be_nil }
    end

    it 'sets a complete translation of a localized attribute' do
      page = build_page(title: { en: 'Hello world', fr: 'Salut le monde' })
      page.title.should eq 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { page.title.should == 'Salut le monde' }
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
      Locomotive::Mounter.with_locale(:fr) { page.title = 'Salut le monde' }
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

  describe 'layout' do

    it 'is not a layout by default' do
      page = build_page
      page.is_layout?.should be_false
    end

    it 'is a layout if it says so' do
      page = build_page(is_layout: true)
      page.is_layout?.should be_true
    end

  end

  describe 'extending a template' do

    it 'extends an template if the raw template includes the extends liquid tag' do
      page = build_page(raw_template: "   \n\t{% extends index %} Lorem ipsum")
      page.extends_template?.should be_true
    end

    it 'does not extend a template because the raw template does not include the extends liquid tag' do
      page = build_page(raw_template: 'Lorem ipsum')
      page.extends_template?.should be_false
    end

    it 'does not extend a template if the raw template is nil' do
      build_page.extends_template?.should be_false
    end

    it 'does not extend a template if the raw template is empty' do
      template = Locomotive::Mounter::Utils::YAMLFrontMattersTemplate.new(File.join(File.dirname(__FILE__), '../..', 'fixtures', 'empty.liquid.haml'))
      build_page(template: template).extends_template?.should be_false
    end

    it 'returns the fullpath to the template' do
      page = build_page(raw_template: "   \n\t{% extends index %} Lorem ipsum")
      page.template_fullpath.should == 'index'

      page = build_page(raw_template: "   \n\t{% extends 'parent' %} Lorem ipsum")
      page.template_fullpath.should == 'parent'
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
      Locomotive::Mounter.with_locale(:fr) do
        @page.fullpath = 'a-notre-sujet/jean-personne'
        @page.slug.should == 'jean-personne'
      end
      @page.slug.should == 'john-doe'
    end

  end

  describe 'adding child' do

    before(:each) do
      @page = build_page(:fullpath => 'index')
      @child = build_page(:title => 'Child', :slug => 'child')
      @page.add_child(@child)
    end

    it 'stores it' do
      @page.children.size.should == 1
      @page.children.first.title.should == 'Child'
    end

    it 'sets the parent of the child' do
      @child.parent.should == @page
    end

    describe 'localizing the fullpath' do

      before(:each) do
        @sub_child = build_page(:title => 'Child', :slug => { :en => 'sub-child', :fr => 'sous-enfant' })
        @child.add_child(@sub_child)
      end

      it 'localizes the index page for all the locales' do
        @page.localize_fullpath([:en, :fr, :de])
        [:fr, :de].each do |locale|
          Locomotive::Mounter.with_locale(locale) { @page.fullpath.should == 'index' }
        end
      end

      it 'takes the slug as the fullpath for first level pages' do
        @child.localize_fullpath([:en, :fr])
        @child.fullpath.should == 'child'
      end

      it 'takes the default locale to fill the fullpath' do
        @child.localize_fullpath([:en, :fr])
        Locomotive::Mounter.with_locale(:fr) { @child.fullpath.should == 'child' }
      end

      it 'takes the parent fullpath to localize the fullpath of a child' do
        [@page, @child].each { |p| p.localize_fullpath([:en, :fr]) }
        @sub_child.localize_fullpath([:en, :fr])
        Locomotive::Mounter.with_locale(:fr) { @sub_child.fullpath.should == 'child/sous-enfant' }
      end

    end

  end

  describe 'deprecated methods' do

    it 'responds to the model setter' do
      Locomotive::Mounter.logger.should_receive(:warn).with('The model attribute is deprecated. Use content_type instead.')
      page = build_page(model: 'something')
      page.content_type.should == 'something'
    end

  end

  def build_page(attributes = {})
    Locomotive::Mounter::Models::Page.new(attributes)
  end

end
