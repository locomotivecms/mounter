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
      page.title.should == 'Hello world'
      I18n.with_locale(:fr) { page.title.should be_nil }

    end

    it 'sets a complete translation of a localized attribute' do
      page = build_page(title: { en: 'Hello world', fr: 'Salut le monde' })
      page.title.should == 'Hello world'
      I18n.with_locale(:fr) { page.title.should == 'Salut le monde' }
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

  def build_page(attributes = {})
    Locomotive::Mounter::Models::Page.new(attributes)
  end

end
