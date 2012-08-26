require 'spec_helper'

describe Locomotive::Mounter::Models::Snippet do

  it 'builds an empty snippet' do
    build_snippet.should_not be_nil
  end

  describe 'building a snippet from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_snippet(template_filepath: 'Hello world')
      }.should raise_exception
    end

    it 'sets a simple attribute' do
      build_snippet(name: 'Header').name.should == 'Header'
    end

    it 'sets a localized attribute' do
      snippet = build_snippet(template: 'header.liquid.haml')
      snippet.template.should == 'header.liquid.haml'
      Locomotive::Mounter.with_locale(:fr) { snippet.template.should be_nil }

    end

    it 'sets a complete translation of a localized attribute' do
      snippet = build_snippet(template: { en: 'header.liquid.haml', fr: 'header.fr.liquid.haml' })
      snippet.template.should == 'header.liquid.haml'
      Locomotive::Mounter.with_locale(:fr) { snippet.template.should == 'header.fr.liquid.haml' }
    end

  end

  describe 'setting attributes' do

    before(:each) do
      @snippet = build_snippet
    end

    it 'sets a simple attribute' do
      @snippet.name = 'Header'
      @snippet.name.should == 'Header'
    end

    it 'sets a localized attribute' do
      @snippet.template = 'header.liquid.haml'
      @snippet.template.should == 'header.liquid.haml'
      @snippet.template_translations[:en].should == 'header.liquid.haml'
    end

  end

  def build_snippet(attributes = {})
    Locomotive::Mounter::Models::Snippet.new(attributes)
  end

end
