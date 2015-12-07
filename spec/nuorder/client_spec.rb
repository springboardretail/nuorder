require 'spec_helper'

describe Nuorder::Client do
  include_examples 'options client'

  specify { expect { described_class.new }.not_to raise_error }

  subject(:client) do
    described_class.new(options_client)
  end

  describe 'module configuration' do
    let (:opts) do
      {
        app_name: 'My APP',
        oauth_callback: 'app.example.com/callback',
        oauth_consumer_key: 'asdfa232042sdafal'
      }
    end

    describe 'with options' do
      it "doesn't share state with global options" do
        client = Nuorder::Client.new(opts)

        Nuorder.configure do |config|
          config.app_name = 'Nuorder app'
        end
        expect(client.app_name).to eq('My APP')
      end

      it 'overrides module configuration' do
        client = Nuorder::Client.new(opts)
        expect(client.app_name).to eq('My APP')
        expect(client.oauth_callback).to eq('app.example.com/callback')
        expect(client.oauth_consumer_key).to eq('asdfa232042sdafal')
      end
    end

    describe '#configure' do
      it 'overrides module configuration' do
        client.configure do |config|
          config.app_name = opts[:app_name]
          config.oauth_callback = opts[:oauth_callback]
          config.oauth_consumer_key = opts[:oauth_consumer_key]
        end
        expect(client.app_name).to eq('My APP')
        expect(client.oauth_callback).to eq('app.example.com/callback')
        expect(client.oauth_consumer_key).to eq('asdfa232042sdafal')
      end
    end
  end

  describe '#api_initiate' do
    let(:client) do
      described_class.new(
        options_client.merge(oauth_token: nil, oauth_token_secret: nil)
      )
    end

    it 'returns temp oauth_token and oauth_token_secret from API', :vcr do
      client.api_initiate

      expect(client.oauth_token).not_to be_nil
      expect(client.oauth_token_secret).not_to be_nil
    end
  end

  describe '#get_oauth_token' do
    it 'returns real oauth_token and oauth_token_secret from API', :vcr do
      oauth_verifier = 'aKRzurszYEA9mpun'
      client.oauth_token = 'p5UzX46KqwdB5Bj3'
      client.oauth_token_secret = 'YaRS2Vy9uSEDVhwu95NaCDPQ'
      client.get_oauth_token(oauth_verifier)
      expect(client.oauth_token).not_to be_nil
      expect(client.oauth_token_secret).not_to be_nil
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

  describe '#process_order' do
    let (:order) do
      {
        '_id' => "whatever",
        'a' => 1,
      }
    end

    before do
      allow(client).to receive(:process_order).with(order).and_return(order)
      @order = client.process_order(order)
    end

    it 'returns extra details of products' do
      expect(@order['_id']).to eq 'whatever'
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
