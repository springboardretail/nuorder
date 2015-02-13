module Nuorder
  class Oauth
    VERSION = '1.0'
    SIGNATURE_METHOD = 'HMAC-SHA1'

    attr_accessor :callback, :consumer_key, :consumer_secret, :token, :token_secret

    def initialize(app_name, base_uri, config)
      @app_name = app_name
      @base_uri = base_uri

      @callback = config[:oauth_callback] || 'oob'
      @consumer_key = config[:oauth_consumer_key]
      @consumer_secret = config[:oauth_consumer_secret]
      @token = config[:oauth_token]
      @token_secret = config[:oauth_token_secret]
    end

    def headers(method, url, addons = nil)
      time = Time.now.to_i
      nonce = SecureRandom.hex(8)
      signature = build_signature(method, url, time, nonce, addons)
      oauth_header = build_oauth(time, nonce, signature, addons)
      {
        'Authorization' => "oAuth #{oauth_header}",
        'Accept'        => 'application/json',
        'Content-Type'  => 'application/json'
      }
    end

    private

    def build_signature(method, url, time, nonce, addons)
      base = "#{method}#{@base_uri}#{url}?"
      base << "oauth_consumer_key=#{consumer_key}"
      base << "&oauth_token=#{token}"
      base << "&oauth_timestamp=#{time}"
      base << "&oauth_nonce=#{nonce}"
      base << "&oauth_version=#{VERSION}&oauth_signature_method=#{SIGNATURE_METHOD}"
      base << "&oauth_verifier=#{addons['oauth_verifier']}" if addons && addons.include?('oauth_verifier')
      base << "&oauth_callback=#{addons['oauth_callback']}" if addons && addons.include?('oauth_callback')
      key = [consumer_secret, token_secret].join('&')
      digest = OpenSSL::Digest.new('sha1')
      OpenSSL::HMAC.hexdigest(digest, key, base)
    end

    def build_oauth(time, nonce, signature, addons)
      oauth = {
        'oauth_consumer_key'     => consumer_key,
        'oauth_timestamp'        => time,
        'oauth_nonce'            => nonce,
        'oauth_version'          => VERSION,
        'oauth_signature_method' => SIGNATURE_METHOD,
        'oauth_token'            => token,
        'oauth_signature'        => signature
      }
      oauth.merge!(addons) unless addons.nil?
      oauth.map { |k, v| "#{k}=#{v}" }.join(',')
    end
  end
end
