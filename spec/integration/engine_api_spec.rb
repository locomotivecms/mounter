require 'spec_helper'

describe Locomotive::Mounter::EngineApi do

  let(:credentials) { { uri: 'sample.example.com:8080/locomotive/api', email: 'did@nocoffee.fr', password: 'test31' } }

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