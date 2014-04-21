require 'spec_helper'

describe 'Locomotive::Mounter::Reader::FileSystem::ContentEntriesReader' do

  let!(:runner) { Locomotive::Mounter::Reader::FileSystem.instance }
  let(:reader) { Locomotive::Mounter::Reader::FileSystem::ContentEntriesReader.new runner }
  before do
    stub_readers runner, %w{content_entries content_types}
    runner.run! path: path
  end

  describe '#all_slugs', focused: true do
    let(:path) { site_path 'simple' }
    subject { reader.all_slugs }
    it { should eql [['products','useless-stuff']] }
  end
end