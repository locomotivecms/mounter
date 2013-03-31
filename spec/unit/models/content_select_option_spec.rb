require 'spec_helper'

describe Locomotive::Mounter::Models::ContentSelectOption do

  it 'builds an empty content select option' do
    build_option.should_not be_nil
  end

  describe 'building a content select option from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_option(label: 'Hello world')
      }.should raise_exception
    end

    it 'sets a simple attribute' do
      build_option(name: 'simple').name.should == 'simple'
    end

    it 'sets a localized attribute' do
      option = build_option(name: 'Hello world')
      option.localized_field?(:name).should be_true
      option.name.should == 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { option.name.should be_nil }

    end

    it 'sets a complete translation of a localized attribute' do
      option = build_option(name: { en: 'Hello world', fr: 'Salut le monde' })
      option.name.should == 'Hello world'
      Locomotive::Mounter.with_locale(:fr) { option.name.should == 'Salut le monde' }
    end

  end

  def build_option(attributes = {})
    Locomotive::Mounter::Models::ContentSelectOption.new(attributes)
  end

end
