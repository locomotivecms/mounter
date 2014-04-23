require 'spec_helper'
require 'locomotive/mounter/collection'

describe Locomotive::Mounter::Collection do

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

  let(:alex) {
    OpenStruct.new firstname: 'Alex',
                   lastname: 'Turam',
                   email: 'alex@example.com',
                   age: 26
  }

  let(:base_items) do
    {
      'john-doe' => john,
      'jane-doe' => jane,
      'alex-turam' => alex,
    }
  end

  context 'filtering items' do
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
        subject.where('age.gt' => 21).should eq [john, alex]
      end

      it 'lt' do
        subject.where('age.lt' => 21).should eq [jane]
      end

      it 'in' do
        subject.where('firstname.in' => ['John','Jane']).should eq [john, jane]
      end

      it 'ordering' do
        subject.where('order_by' => 'firstname asc').first.should eq alex
      end

      it 'ordering DESC' do
        subject.where('order_by' => 'firstname desc').first.should eq john
      end
    end
  end
end