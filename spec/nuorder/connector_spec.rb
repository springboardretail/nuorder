require 'spec_helper'

describe Nuorder::Connector do
  include_examples 'config hash'
  let(:app_name) { 'TEST-app' }
  let(:base_uri) { 'http://buyer.sandbox1.nuorder.com' }

  specify { expect { described_class.new(app_name, base_uri, {}) }.not_to raise_error }
  
  subject(:connector) do
    described_class.new(app_name, base_uri, config)
  end

  specify { expect(connector.respond_to?(:oauth)).to be true }

  describe '#api_initiate' do
    before do
      connector.oauth.token = nil
      connector.oauth.token_secret = nil
    end

    it 'returns temp oauth_token and oauth_token_secret from API', :vcr do
      connector.api_initiate
      expect(connector.oauth.token).not_to be_nil
      expect(connector.oauth.token_secret).not_to be_nil
    end
  end
  
  describe '#get_oauth_token' do
    it 'returns real oauth_token and oauth_token_secret from API', :vcr do
      oauth_verifier = 'aKRzurszYEA9mpun'
      connector.oauth.token = 'p5UzX46KqwdB5Bj3'
      connector.oauth.token_secret = 'YaRS2Vy9uSEDVhwu95NaCDPQ'
      
      connector.get_oauth_token(oauth_verifier)
      expect(connector.oauth.token).not_to be_nil
      expect(connector.oauth.token_secret).not_to be_nil
    end

    context 'no oauth_verifier provided' do
      specify { expect { connector.get_oauth_token(nil) }.to raise_error('No oauth_verifier') }
    end
  end

  describe '#get' do
    it 'raises error if NuOrder api returns error', :vcr do
      expect { connector.get("/api/product/541204aca01ceed9650486a2") }
        .to raise_error(Nuorder::ApiError)
    end
  end
end
