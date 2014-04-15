require 'spec_helper'
require 'locomotive/mounter/reader/file_system/collection'

describe Locomotive::Mounter::Reader::FileSystem::Collection do
  context "fetching item" do
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
end