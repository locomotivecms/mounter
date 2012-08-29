require 'spec_helper'

describe Locomotive::Mounter::Reader::FileSystem do

  before(:each) do
    @reader = Locomotive::Mounter::Reader::FileSystem.instance
  end

  it 'returns nil if the path does not exist' do
    lambda {
      @reader.run!
    }.should raise_exception(Locomotive::Mounter::ReaderException, 'path is required and must exist')
  end

end