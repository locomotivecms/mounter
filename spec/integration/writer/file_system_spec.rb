require 'spec_helper'

describe Locomotive::Mounter::Writer::FileSystem do

  before(:each) do
    @source_path    = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'default')
    @target_path    = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'default')
    @mounting_point = Locomotive::Mounter::Reader::FileSystem.instance.run!(:path => @source_path)
    @writer         = Locomotive::Mounter::Writer::FileSystem.instance
  end

  it 'runs it' do
    @writer.run!(:mounting_point => @mounting_point, :target_path => @target_path).should_not be_nil
  end

end