require 'spec_helper'

describe Locomotive::Mounter::Models::ContentEntry do

  it 'builds an empty content entry' do
    build_content_entry.should_not be_nil
  end

  describe 'building a content entry from attributes' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_content_entry(foo: 'Hello world')
      }.should raise_exception
    end

  end

  describe 'setting attributes' do

    before(:each) do
      @content_entry = build_content_entry
    end

    it 'sets a simple attribute' do
      @content_entry._position = 0
      @content_entry._position.should == 0
    end

    it 'sets a localized attribute' do
      @content_entry.seo_title = 'Hello world'
      @content_entry.seo_title.should == 'Hello world'
      @content_entry.seo_title_translations[:en].should == 'Hello world'
    end

  end

  describe 'dynamic fields' do

    before(:each) do
      @content_type   = mock
      @content_entry  = build_content_entry(content_type: @content_type)
    end

    it 'returns false if it is not a dynamic field' do
      @content_type.stubs(:find_field).with(:title).returns(nil)
      @content_entry.is_dynamic_field?(:title).should be_false
    end

    it 'returns true if it is a dynamic field' do
      @content_type.stubs(:find_field).with(:title).returns(true)
      @content_entry.is_dynamic_field?(:title).should be_true
    end

    describe 'when defined' do

      before(:each) do
        (@content_field = mock).stubs(:is_relationship?).returns(false)
        @content_type.stubs(:find_field).with(:title).returns(@content_field)
      end

      it 'can be set' do
        @content_entry.title = 'Hello world'
        @content_entry.dynamic_attributes[:title].should == { :en => 'Hello world' }
      end

      it 'returns nil if not set' do
        @content_field.stubs(:type).returns(:string)
        @content_entry.title.should == nil
      end

      it 'can be retrieved' do
        @content_field.stubs(:type).returns(:string)
        @content_entry.title = 'Hello world'
        @content_entry.title.should == 'Hello world'
      end

      it 'returns the value of the label bound to a dynamic field' do
        @content_field.stubs(:type).returns(:string)
        @content_type.stubs(:label_field_name).returns(:title)
        @content_entry._label.should == nil
        @content_entry.title = 'Hello world'
        @content_entry._label.should == 'Hello world'
      end

      describe 'and localized' do

        before(:each) do
          @content_field.stubs(:type).returns(:string)
          @content_entry.title = 'Hello world'
        end

        it 'does not have a value for other locales' do
          Locomotive::Mounter.with_locale(:fr) do
            @content_entry.title.should be_nil
          end
        end

        it 'can assign a different value of another locale' do
          Locomotive::Mounter.with_locale(:fr) do
            @content_entry.title = 'Bonjour le monde'
            @content_entry.title.should == 'Bonjour le monde'
          end
          @content_entry.title.should == 'Hello world'
        end

        it 'is does not use a localized value for relationship kind field' do
          (@target_content_type = mock).stubs(:find_entry).with('john-doe').returns('john-doe')
          @content_field.stubs(:is_relationship?).returns(true)
          @content_field.stubs(:klass).returns(@target_content_type)
          @content_field.stubs(:type).returns(:belongs_to)

          @content_type.stubs(:find_field).with(:author).returns(@content_field)

          @content_entry.author = 'john-doe'
          Locomotive::Mounter.with_locale(:fr) do
            @content_entry.author.should == 'john-doe'
          end
        end

      end

    end

  end

  def build_content_entry(attributes = {})
    Locomotive::Mounter::Models::ContentEntry.new(attributes)
  end

end