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
      options = Nuorder::Default.options.merge(options)
      set_instance_variables(options)
    end

    def same_options?(opts)
      opts.hash == options.hash
    end

    def api_initiate
      addons = { 'application_name' => @app_name, 'oauth_callback' => @oauth_callback }
      headers = oauth_headers('GET', '/api/initiate', addons)
      response = connection.get '/api/initiate', {}, headers

      @oauth_token = response.body['oauth_token']
      @oauth_token_secret = response.body['oauth_token_secret']

      response
    end

    def get_oauth_token(oauth_verifier)
      fail 'No oauth_verifier' unless oauth_verifier

      headers = oauth_headers('GET', '/api/token', { 'oauth_verifier' => oauth_verifier })
      response = connection.get '/api/token', {}, headers

      @oauth_token = response.body['oauth_token']
      @oauth_token_secret = response.body['oauth_token_secret']

      response
    end

    def get(url, params: nil)
      headers = oauth_headers('GET', url)
      response = connection.get url, params, headers
      validate_response(response)
    end


    def post(url, params: nil)
      headers = oauth_headers('POST', url)
      response = connection.post url, params, headers
      validate_response(response)
    end

    def orders(status:)
      get("/api/orders/#{status}/detail").body
    end

    def product(id:)
      get("/api/product/#{id}").body
    end

    def process_order(order)
      order_id = order["_id"]
      post("/api/order/#{order_id}/process").body
    end

    def orders_with_product_details(status:)
      orders = orders(status: status)
      orders.map! do |order|
        add_product_details!(line_items: order['line_items'])
        order
      end
    end

    private

    # Set instance variables passed in options
    def set_instance_variables(options)
      Nuorder::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key])
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

    def add_product_details!(line_items:)
      line_items.map! do |line_item|
        product_id = line_item['product']['_id']
        product_details = product(id: product_id)
        line_item['product'].merge!(product_details)
        line_item
      end
    end
  end
end
