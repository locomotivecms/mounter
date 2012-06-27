require 'spec_helper'

describe Locomotive::Mounter::Models::ContentType do

  it 'builds an empty content type' do
    build_content_type.should_not be_nil
  end

  describe 'building a content type from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_content_type(foo: 'Hello world')
      }.should raise_exception
    end

  end

  describe 'fields' do

    before(:each) do
      @fields = [
        { label: 'Title', 'name' => 'title' },
        { label: 'Description', 'name' => :description, type: :text }
      ]
    end

    it 'has 2 fields' do
      build_content_type(fields: @fields).fields.size.should == 2
    end

    it 'has the right class for each field' do
      build_content_type(fields: @fields).fields.each do |field|
        field.class.should == Locomotive::Mounter::Models::ContentField
      end
    end

    it 'sets the right types' do
      build_content_type(fields: @fields).fields.first.type.should == :string
      build_content_type(fields: @fields).fields.last.type.should == :text
    end

  end

  def build_content_type(attributes = {})
    Locomotive::Mounter::Models::ContentType.new(attributes)
  end

end