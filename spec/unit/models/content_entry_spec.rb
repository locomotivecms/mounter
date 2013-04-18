require 'spec_helper'

describe Locomotive::Mounter::Models::ContentEntry do

  let(:content_type) do
    content_type = mock
    content_field = stub('TitleField', name: :title, type: :string, is_relationship?: false, localized: false)
    content_type.stubs(:label_field).returns(content_field)
    content_type.stubs(:label_field_name).returns(:title)
    content_type.stubs(:find_field).with(:title).returns(content_field)
    content_type.stubs(:label_to_slug).returns('base')
    content_type.stubs(:find_entry).returns(nil)
    content_type.stubs(:mounting_point).returns(mounting_point)

    content_type
  end

  let(:content_entry) { build_content_entry }

  let(:mounting_point) { stub('MountingPoint', default_locale: :en, locales: [:en, :fr]) }

  describe 'setting default attributes' do

    it 'builds an empty content entry' do
      content_entry.should_not be_nil
    end

    it 'sets a simple attribute' do
      content_entry._position = 0
      content_entry._position.should == 0
    end

    it 'sets a localized attribute' do
      content_entry.seo_title = 'Hello world'
      content_entry.seo_title.should == 'Hello world'
      content_entry.seo_title_translations[:en].should == 'Hello world'
    end

  end

  describe 'dynamic fields' do

    it 'raises an exception of the field does not exist' do
      lambda {
        build_content_entry(foo: 'Hello world')
      }.should raise_exception
    end

    it 'returns false if it is not a dynamic field' do
      content_type.stubs(:find_field).with(:text).returns(nil)
      content_entry.is_dynamic_field?(:text).should be_false
    end

    it 'returns true if it is a dynamic field' do
      content_entry.is_dynamic_field?(:title).should_not be_nil
    end

    describe 'when defined' do

      let(:content_field) { stub(name: :text, type: :text, is_relationship?: false, localized: true, required: true) }

      before(:each) do
        content_type.stubs(:find_field).with(:text).returns(content_field)
        content_type.stubs(:fields).returns([content_field])
      end

      it 'returns nil if not set' do
        content_entry.text.should == nil
      end

      it 'can be set' do
        content_entry.text = 'Hello world'
        content_entry.dynamic_attributes[:text].should == { en: 'Hello world' }
      end

      it 'can be retrieved' do
        content_entry.title = 'Hello world'
        content_entry.title.should == 'Hello world'
      end

      it 'returns the value of the label bound to a dynamic field' do
        content_entry._label.should == nil
        content_entry.title = 'Hello world'
        content_entry._label.should == 'Hello world'
      end

      describe 'and localized' do

        before(:each) do
          content_entry.text = 'Hello world'
        end

        it 'keeps track of the locale used at first' do
          content_entry.main_locale.should == :en
        end

        it 'can return the slug in the default locale if it is nil in the current one' do
          Locomotive::Mounter.with_locale(:fr) do
            content_entry._slug.should == 'base'
          end
        end

        it 'uses the value of the main locale' do
          Locomotive::Mounter.with_locale(:fr) do
            content_entry.text.should == 'Hello world'
          end
          content_entry.main_locale.should == :en
        end

        it 'can assign a different value of another locale' do
          Locomotive::Mounter.with_locale(:fr) do
            content_entry.text = 'Bonjour le monde'
            content_entry.text.should == 'Bonjour le monde'
          end
          content_entry.text.should == 'Hello world'
        end

        it 'is does not use a localized value for relationship kind field' do
          (target_content_type = mock).stubs(:find_entry).with('john-doe').returns('john-doe')
          _field = stub('AuthorField', name: :author, type: :belongs_to, 'is_relationship?' => true, klass: target_content_type)
          content_type.expects(:find_field).with(:author).at_least(1).returns(_field)

          content_entry.author = 'john-doe'
          Locomotive::Mounter.with_locale(:fr) do
            content_entry.author.should == 'john-doe'
          end
        end

        describe 'getters / setters' do

          before(:each) do
            content_entry.title = 'Hello world'
            content_entry.text  = 'Lorem ipsum'

            Locomotive::Mounter.with_locale(:fr) do
              content_entry.text  = 'Lorem ipsum (FR)'
            end
          end

          it 'stores the list of dynamic fields' do
            content_entry.dynamic_fields.count.should == 2
          end

          it 'can loop over the dynamic fields' do
            attributes = {}
            content_entry.each_dynamic_field { |f, v| attributes[f.name.to_s] = v }
            attributes.should == { 'title' => 'Hello world', 'text' => 'Lorem ipsum' }

            Locomotive::Mounter.with_locale(:fr) do
              content_entry.each_dynamic_field { |f, v| attributes[f.name.to_s] = v }
              attributes.should == { 'title' => 'Hello world', 'text' => 'Lorem ipsum (FR)' }
            end
          end

        end

      end

      describe '.valid?' do

        it 'returns false if the required fields are empty' do
          content_entry.valid?.should be_false
        end

        it 'returns true if the required fields are present' do
          content_entry.text = 'Hello world'
          content_entry.valid?.should be_true
        end

      end

      describe 'timestamps' do

        it 'has a not nil created_at field' do
          content_entry.created_at.should_not be_nil
        end

        it 'has a not nil updated_at field' do
          content_entry.created_at.should_not be_nil
        end

        it 'can be set' do
          date = Time.parse('2013-03-24')
          another_entry = build_content_entry(created_at: date)
          another_entry.created_at.should == date
        end

      end

    end

  end

  def build_content_entry(attributes = {})
    Locomotive::Mounter::Models::ContentEntry.new(attributes.merge(content_type: content_type)).tap do |entry|
      entry.mounting_point = content_type.mounting_point
      entry.send(:set_slug)
    end
  end

end