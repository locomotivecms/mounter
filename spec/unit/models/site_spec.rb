require 'spec_helper'

describe Locomotive::Mounter::Models::Site do

  it 'builds an empty site' do
    build_site.should_not be_nil
  end

  describe 'building a site from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_site(template: 'Hello world')
      }.should raise_exception
    end

    it 'sets a simple attribute' do
      build_site(name: 'Hello world').name.should == 'Hello world'
    end

    it 'sets a more complex attribute' do
      build_site(locales: %w(en fr)).locales.should == %w(en fr)
    end

    it 'sets a localized attribute' do
      site = build_site(seo_title: 'Hello world')
      site.seo_title.should == 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { site.seo_title.should be_nil }

    end

    it 'sets a complete translation of a localized attribute' do
      site = build_site(seo_title: { en: 'Hello world', fr: 'Salut le monde' })
      site.seo_title.should == 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { site.seo_title.should == 'Salut le monde' }
    end

  end

  describe 'setting attributes' do

    before(:each) do
      @site = build_site
    end

    it 'sets a simple attribute' do
      @site.name = 'Hello world'
      @site.name.should == 'Hello world'
    end

    it 'sets a localized attribute' do
      @site.seo_title = 'Hello world'
      @site.seo_title.should == 'Hello world'
      @site.seo_title_translations[:en].should == 'Hello world'
    end

  end

  describe 'retrieving attributes' do

    before(:each) do
      @site = build_site(name: 'Hello world', seo_title: 'A title', meta_description: { en: 'Hello world', fr: 'Salut le monde' })
    end

    it 'returns all of them' do
      @site.attributes.should == { name: 'Hello world', locales: nil, seo_title: 'A title', meta_keywords: nil, meta_description: 'Hello world', subdomain: nil, domains: nil, robots_txt: nil, timezone: nil }
    end

    it 'returns a localized version' do
      Locomotive::Mounter.with_locale(:fr) do
        @site.attributes.should == { name: 'Hello world', locales: nil, seo_title: nil, meta_keywords: nil, meta_description: 'Salut le monde', subdomain: nil, domains: nil, robots_txt: nil, timezone: nil }
      end
    end

    it 'returns all of them and their translations' do
      @site.attributes_with_translations.should == { name: 'Hello world', locales: nil, seo_title: 'A title', meta_keywords: nil, meta_description: { en: 'Hello world', fr: 'Salut le monde' }, subdomain: nil, domains: nil, robots_txt: nil, timezone: nil }
    end

  end

  def build_site(attributes = {})
    Locomotive::Mounter::Models::Site.new(attributes)
  end

end
