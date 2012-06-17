require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  before(:each) do
    @reader = Locomotive::Mounter::Reader::FileSystem.new
  end

  it 'returns nil if the path does not exist' do
    @reader.run!.should be_nil
  end

end