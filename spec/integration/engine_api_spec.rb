require 'spec_helper'

describe Locomotive::Mounter::EngineApi, :vcr do

  before(:all) do
    setup "engine_api_setup"
    @uri = 'www.example.com:3000/locomotive/api'
  end

  before(:each) do
    teardown
  end

  it 'handles smoothly wrong credentials' do
    lambda do
      Locomotive::Mounter::EngineApi.set_token @uri, credentials[:email], 'wrong'
    end.should raise_exception(Locomotive::Mounter::WrongCredentials)
  end

  describe 'correct credentials' do

    it 'accepts a hash as credentials' do
      token = Locomotive::Mounter::EngineApi.set_token credentials.merge!(uri: @uri)
      token.should_not be_nil
    end

    it 'accepts credentials individually' do
      token = Locomotive::Mounter::EngineApi.set_token @uri, credentials[:email], credentials[:password]
      token.should_not be_nil
    end

    it 'accepts an api key instead' do
      _credentials = { uri: @uri, api_key: 'd49cd50f6f0d2b163f48fc73cb249f0244c37074'}
      token = Locomotive::Mounter::EngineApi.set_token _credentials
    end

  end

end