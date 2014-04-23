require 'spec_helper'
require 'locomotive/mounter/collection'

describe Locomotive::Mounter::Collection do

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
    subject { Locomotive::Mounter::Collection.new(base_items) }

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