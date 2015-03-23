require 'nuorder/version'
require 'nuorder/client'
require 'nuorder/configurable'
require 'nuorder/default'

module Nuorder
  class ApiError < StandardError; end
  extend Nuorder::Configurable

  class << self
    def client
      @client = Nuorder::Client.new(options) unless defined?(@client) && @client.same_options?(options)
      @client
    end

    def respond_to_missing?(method_name, include_private = false)
      client.respond_to?(method_name, include_private)
    end

    def method_missing(method_name, *args, &block)
      client.send(method_name, *args, &block)
    end
  end

end

Nuorder.setup
