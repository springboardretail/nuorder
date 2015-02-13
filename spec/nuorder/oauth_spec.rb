require 'spec_helper'

describe Nuorder::Oauth do
  include_examples 'config hash'
  let(:app_name) { 'TEST-app' }
  let(:base_uri) { 'http://buyer.sandbox1.nuorder.com' }

  specify { expect { described_class.new(app_name, base_uri, config) }.not_to raise_error }

  subject(:oauth) do
    described_class.new(app_name, base_uri, config)
  end

  [:callback, :consumer_key, :consumer_secret, :token, :token_secret].each do |accessor|
    specify { expect(oauth.respond_to? accessor).to be true }
  end

  describe '#initialize' do
    context 'without url_callback' do
      it 'sets url_callback to "oob"' do
        url_callback = oauth.callback
        expect(url_callback).to eq 'oob'
      end
    end

    context 'with url_callback' do
      let(:url_callback) { 'app.example.com/callback' }
      let(:new_config) { config.merge(oauth_callback: url_callback) }
      let(:oauth_with_callback) { described_class.new(app_name, base_uri, new_config) }

      it 'sets url_callback' do
        expect(oauth_with_callback.callback).to eq url_callback
      end
    end
  end

  describe '#headers' do
    specify { expect(oauth.respond_to? :headers).to be true }
    let (:headers) { oauth.headers('GET', '/api/product/123') }

    specify { expect(headers).not_to be_nil }

    ['Authorization', 'Accept', 'Content-Type'].each do |header_key|
      specify { expect(headers.key? header_key).to be true }
    end
  end
end
