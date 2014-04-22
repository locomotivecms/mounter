require 'spec_helper'
require 'locomotive/mounter/reader/file_system/collection'

describe Locomotive::Mounter::Reader::FileSystem::Collection do

  context 'fetching item' do
    subject { Locomotive::Mounter::Reader::FileSystem::Collection.new(reader) }
    let(:reader) do
      double.tap do |reader|
        allow(reader).to receive(:fetch_one).with(an_instance_of(String)) { |slug| "new_#{slug}" }
      end
    end

    it "fetches non existing items" do
      subject['test_slug'].should eq 'new_test_slug'
    end
  end

  context 'filtering items' do
    let(:john) {
      OpenStruct.new firstname: 'John',
                     lastname: 'Doe',
                     email: 'john@example.com',
                     age: 24
    }
    let(:jane) {
      OpenStruct.new firstname: 'Jane',
                     lastname: 'Doe',
                     email: 'jane@example.com',
                     age: 20
    }

    let(:base_items) do
      {
        'john-doe' => john,
        'jane-doe' => jane
      }
    end
    subject { Locomotive::Mounter::Reader::FileSystem::Collection.new(nil) }
    before { subject.stub(all: base_items.values) }

    context '#where' do
      it 'simple key value pair' do
        subject.where('lastname' => 'Doe').should eq [john, jane]
      end

      it 'multiple key value pair' do
        subject.where('firstname' => 'John', 'lastname' => 'Doe').should eq [john]
      end

      it 'unkown key returns empty resultset' do
        subject.where('fake' => 'Key').should eq []
      end
      it 'symbolized keys' do
        subject.where(firstname: 'John').should eq [john]
      end

      it 'gt' do
        subject.where('age.gt' => 21).should eq [john]
      end

      it 'lt' do
        subject.where('age.lt' => 21).should eq [jane]
      end

      it 'in' do
        subject.where('firstname.in' => ['John','Jane']).should eq [john, jane]
      end

    end
  end
end