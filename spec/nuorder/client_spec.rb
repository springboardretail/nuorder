require 'spec_helper'

describe Nuorder::Client do
  before do
    Nuorder.reset!
  end

  after do
    Nuorder.reset!
  end

  include_examples 'options client'

  specify { expect { described_class.new }.not_to raise_error }
  
  subject(:client) do
    described_class.new(options_client)
  end

  describe 'module configuration' do
    before do
      Nuorder.reset!
      Nuorder.configure do |config|
        Nuorder::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      Nuorder.reset!
    end

    it 'inherits the module configuration' do
      client = Nuorder::Client.new
      Nuorder::Configurable.keys.each do |key|
        expect(client.instance_variable_get(:"@#{key}")).to eq("Some #{key}")
      end
    end

    describe 'with options' do
      let (:opts) do
        {
            app_name: 'My APP',
            oauth_callback: 'app.example.com/callback',
            oauth_consumer_key: 'asdfa232042sdafal'
        }
      end

      it 'overrides module configuration' do
        client = Nuorder::Client.new(opts)
        expect(client.app_name).to eq('My APP')
        expect(client.oauth_callback).to eq('app.example.com/callback')
        expect(client.oauth_consumer_key).to eq('asdfa232042sdafal')
      end
    end
  end

  describe '#api_initiate' do
    before do
      Nuorder.configure do |config|
        config.oauth_token = nil
        config.oauth_token_secret = nil
      end
    end

    it 'returns temp oauth_token and oauth_token_secret from API', :vcr do
      client.api_initiate

      expect(Nuorder.oauth_token).not_to be_nil
      expect(Nuorder.oauth_token_secret).not_to be_nil
    end
  end
  
  describe '#get_oauth_token' do
    it 'returns real oauth_token and oauth_token_secret from API', :vcr do
      oauth_verifier = 'aKRzurszYEA9mpun'
      Nuorder.oauth_token = 'p5UzX46KqwdB5Bj3'
      Nuorder.oauth_token_secret = 'YaRS2Vy9uSEDVhwu95NaCDPQ'
      
      client.get_oauth_token(oauth_verifier)
      expect(Nuorder.oauth_token).not_to be_nil
      expect(Nuorder.oauth_token_secret).not_to be_nil
    end

    context 'no oauth_verifier provided' do
      specify { expect { client.get_oauth_token(nil) }.to raise_error('No oauth_verifier') }
    end
  end

  describe '#get' do
    it 'raises error if NuOrder api returns error', :vcr do
      expect { client.get("/api/product/541204aca01ceed9650486a2") }
        .to raise_error(Nuorder::ApiError)
    end
  end

  describe '#orders_with_product_details' do
    let (:orders_dummy) do
      [
        {
          'a' => 1,
          'line_items' => [
            {'product' => {'_id' => 1, 'b' => 2}},
            {'product' => {'_id' => 2, 'b' => 3}},
          ]
        }
      ]
    end
    let (:product_dummy) do
      {'_id' => 1, 'b' => 4, 'c' => 5 }
    end

    before do
      allow(client).to receive(:orders).and_return(orders_dummy)
      allow(client).to receive(:product).and_return(product_dummy)
      @orders = client.orders_with_product_details(status: 'processed')
    end

    it 'returns extra details of products' do
      first_product = @orders.first['line_items'].first['product']
      expect(first_product.key? 'c').to be true
    end
  end

  describe '#oauth_headers' do
    let (:headers) { client.oauth_headers('GET', '/api/product/123') }

    specify { expect(headers).not_to be_nil }

    ['Authorization', 'Accept', 'Content-Type'].each do |header_key|
      specify { expect(headers.key? header_key).to be true }
    end
  end
end
