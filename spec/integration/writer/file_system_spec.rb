require 'spec_helper'

describe Locomotive::Mounter::Writer::FileSystem do

  let(:target_path) { File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'default') }
  let(:fs_writer)   { Locomotive::Mounter::Writer::FileSystem.instance }

  subject { fs_writer.run!(mounting_point: _mounting_point, target_path: target_path) }

  describe 'from a local site' do

    let(:source_path)     { File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default') }
    let(:_mounting_point)  { Locomotive::Mounter::Reader::FileSystem.instance.run!(path: source_path) }

    it { should_not be_nil }

  end

  describe 'from a remote site', :vcr do

    before(:all)  { setup 'reader_api_setup' }
    after(:all)   { teardown }

    let(:_mounting_point) { Locomotive::Mounter::Reader::Api.instance.run!(credentials) }

    it { should_not be_nil }

  end

end