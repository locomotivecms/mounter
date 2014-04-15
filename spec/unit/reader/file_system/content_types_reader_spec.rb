require 'spec_helper'

describe 'Locomotive::Mounter::Reader::FileSystem::ContentTypesReader' do

  let(:path) { File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'simple') }
  let(:runner) { Locomotive::Mounter::Reader::FileSystem.instance }


  before do
    runner.stub(readers: [Locomotive::Mounter::Reader::FileSystem::ContentTypesReader])
    runner.run!(path: path)
  end
  subject { Locomotive::Mounter::Reader::FileSystem::ContentTypesReader.new(runner) }
  describe '#fetch_one' do
    it "fetches and returns a new content_types model" do
      subject.fetch_one('products').should be_kind_of Locomotive::Mounter::Models::ContentType
    end
  end
end