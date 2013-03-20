require 'spec_helper'

describe Locomotive::Mounter::EngineApi, :vcr do

  let(:credentials) { { uri: 'locomotive.engine.dev:3000/locomotive/api', email: 'admin@locomotivecms.com', password: 'locomotive' } }

  it 'handles smoothly wrong credentials' do
    lambda do
      Locomotive::Mounter::EngineApi.set_token credentials[:uri], credentials[:email], 'wrong'
    end.should raise_exception(Locomotive::Mounter::WrongCredentials)
  end

  describe 'correct credentials' do

    it 'accepts a hash as credentials' do
      token = Locomotive::Mounter::EngineApi.set_token credentials
      token.should_not be_nil
    end

    it 'accepts credentials individually' do
      token = Locomotive::Mounter::EngineApi.set_token credentials[:uri], credentials[:email], credentials[:password]
      token.should_not be_nil
    end

  end

end