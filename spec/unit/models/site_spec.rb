require 'spec_helper'

describe Locomotive::Mounter::Models::Site do

  before(:each) do

  end

  it 'builds an empty site' do
    build_site.should_not not_nil
  end

  def build_site(attributes = {})
    Locomotive::Mounter::Models::Site.new(attributes)
  end

end
