require 'securerandom'

module Nuorder
  class Client
    module Oauth
      VERSION = '1.0'
      SIGNATURE_METHOD = 'HMAC-SHA1'

      def oauth_headers(method, url, addons = nil)
        time = Time.now.to_i
        nonce = SecureRandom.hex(8)
        signature = build_signature(method, url, time, nonce, addons)
        oauth_header = build_oauth(time, nonce, signature, addons)
        {
            'Authorization' => "oAuth #{oauth_header}",
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
        }
      end

      private

      def build_signature(method, url, time, nonce, addons)
        base = "#{method}#{@api_endpoint}#{url}?"
        base << "oauth_consumer_key=#{@oauth_consumer_key}"
        base << "&oauth_token=#{@oauth_token}"
        base << "&oauth_timestamp=#{time}"
        base << "&oauth_nonce=#{nonce}"
        base << "&oauth_version=#{VERSION}&oauth_signature_method=#{SIGNATURE_METHOD}"
        base << "&oauth_verifier=#{addons['oauth_verifier']}" if addons && addons.include?('oauth_verifier')
        base << "&oauth_callback=#{addons['oauth_callback']}" if addons && addons.include?('oauth_callback')
        key = [@oauth_consumer_secret, @oauth_token_secret].join('&')
        digest = OpenSSL::Digest.new('sha1')
        OpenSSL::HMAC.hexdigest(digest, key, base)
      end

      def build_oauth(time, nonce, signature, addons)
        oauth = {
            'oauth_consumer_key' => @oauth_consumer_key,
            'oauth_timestamp' => time,
            'oauth_nonce' => nonce,
            'oauth_version' => VERSION,
            'oauth_signature_method' => SIGNATURE_METHOD,
            'oauth_token' => @oauth_token,
            'oauth_signature' => signature
        }
        oauth.merge!(addons) unless addons.nil?
        oauth.map { |k, v| "#{k}=#{v}" }.join(',')
      end
    end
  end
end
