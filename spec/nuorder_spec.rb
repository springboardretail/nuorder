require 'spec_helper'

describe Nuorder do
  describe '#new' do
    it 'creates a Nuorder::Client' do
      expect(Nuorder.new).to be_kind_of Nuorder::Client
    end
  end

  describe '.client' do
    it 'creates a Nuorder::Client' do
      expect(Nuorder.client).to be_kind_of Nuorder::Client
    end

    it 'caches the client when the same options are passed' do
      expect(Nuorder.client).to eq(Nuorder.client)
    end

    it 'returns a fresh client when options are not the same' do
      client = Nuorder.client
      Nuorder.oauth_token = '87614b09dd141c22800f96f11737ade5226d7ba8'
      client_two = Nuorder.client
      client_three = Nuorder.client
      expect(client).not_to eq(client_two)
      expect(client_three).to eq(client_two)
    end
  end

  describe '.configure' do
    Nuorder::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Nuorder.configure do |config|
          config.send("#{key}=", key)
        end
        expect(Nuorder.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end
end
