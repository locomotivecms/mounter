require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  describe '#run!' do
    let(:reader) { Locomotive::Mounter::Reader::FileSystem.instance }
    subject { reader.run!(path: path) }
    context 'if the path does not exist' do
      let(:path) { nil }
      it 'raises' do
        expect {
          subject
        }.to raise_exception(Locomotive::Mounter::ReaderException, 'path is required and must exist')
      end
    end

    context 'if the path exist' do
      let(:path) { site_path }
      it 'does not raise' do
        expect { subject }.not_to raise_error
      end
    end
  end
end