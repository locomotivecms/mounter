require 'spec_helper'

describe Locomotive::Mounter do

  before(:each) do
    @reader = stub(:run! => 'Hello world')
    Locomotive::Mounter::Config.register(reader: @reader)
  end

  it 'has a valid reader' do
    Locomotive::Mounter::Config[:reader].should_not be_nil
  end

  it 'runs the reader' do
    Locomotive::Mounter.mount({}).should == 'Hello world'
  end

end
