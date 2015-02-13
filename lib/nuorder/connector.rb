require 'faraday'
require 'excon'
require 'faraday_middleware-multi_json'

module Nuorder
  class Connector
    attr_reader :oauth

    def initialize(app_name, base_uri, config)
      @app_name = app_name
      @base_uri = base_uri

      @oauth = Oauth.new(app_name, base_uri, config)
    end

    def api_initiate
      addons = { 'application_name' => @app_name, 'oauth_callback' => @oauth.callback }
      headers = @oauth.headers('GET', '/api/initiate', addons)
      response = connection.get '/api/initiate', {}, headers

      oauth.token = response.body['oauth_token']
      oauth.token_secret = response.body['oauth_token_secret']

      response
    end

    def get_oauth_token(oauth_verifier)
      fail 'No oauth_verifier' unless oauth_verifier

      headers = oauth.headers('GET', '/api/token', { 'oauth_verifier' => oauth_verifier })
      response = connection.get '/api/token', {}, headers

      oauth.token = response.body['oauth_token']
      oauth.token_secret = response.body['oauth_token_secret']

      response
    end

    def get(url, params: nil)
      headers = oauth.headers('GET', url)
      response = connection.get url, params, headers
      validate_response(response)
    end

    private

    def connection
      @connection ||= build_connection
    end

    def build_connection
      Faraday.new(url: @base_uri) do |builder|
        builder.response :multi_json
        builder.adapter :excon, persistent: true
      end
    end

    def validate_response(response)
      return response if [200, 201].include?(response.status)
      fail ApiError, "NuOrder API Error #{response.body['code']}. #{response.body['message']}"
    end
  end
end
