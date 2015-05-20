require 'faraday'
require 'excon'
require 'faraday_middleware-multi_json'
require 'nuorder/configurable'
require 'nuorder/client/oauth'

module Nuorder
  class Client

    include Nuorder::Configurable
    include Nuorder::Client::Oauth

    def initialize(options = {})
      set_instance_variables(options)
    end

    def same_options?(opts)
      opts.hash == options.hash
    end

    def api_initiate
      addons = { 'application_name' => @app_name, 'oauth_callback' => @oauth_callback }
      headers = oauth_headers('GET', '/api/initiate', addons)
      response = connection.get '/api/initiate', {}, headers

      Nuorder.oauth_token = response.body['oauth_token']
      Nuorder.oauth_token_secret = response.body['oauth_token_secret']

      response
    end

    def get_oauth_token(oauth_verifier)
      fail 'No oauth_verifier' unless oauth_verifier

      headers = oauth_headers('GET', '/api/token', { 'oauth_verifier' => oauth_verifier })
      response = connection.get '/api/token', {}, headers

      Nuorder.oauth_token = response.body['oauth_token']
      Nuorder.oauth_token_secret = response.body['oauth_token_secret']

      response
    end

    def get(url, params: nil)
      headers = oauth_headers('GET', url)
      response = connection.get url, params, headers
      validate_response(response)
    end

    def orders(status:)
      get("/api/orders/#{status}/detail").body
    end

    def product(id:)
      get("/api/product/#{id}").body
    end

    def orders_with_product_details(status:)
      orders = orders(status: status)
      orders.each do |order|
        line_items = order['line_items']
        line_items.map do |line_item|
          product_id = line_item['product']['_id']
          product_details = product(id: product_id)
          line_item['product'].merge!(product_details)
        end
      end
      orders
    end

    private

    # Set instance variables passed in options, but fallback to module defaults
    def set_instance_variables(options)
      Nuorder::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Nuorder.instance_variable_get(:"@#{key}"))
      end
    end

    def connection
      @connection ||= build_connection
    end

    def build_connection
      Faraday.new(url: @api_endpoint) do |builder|
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
