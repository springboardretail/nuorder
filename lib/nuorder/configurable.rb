module Nuorder
  module Configurable
    class << self
      def keys
        @keys ||= %i(
          app_name
          api_endpoint
          oauth_callback
          oauth_consumer_key
          oauth_consumer_secret
          oauth_token
          oauth_token_secret
        )
      end
    end

    attr_accessor *Nuorder::Configurable.keys

    # Set configuration options using a block
    def configure
      yield(self) if block_given?
    end

    # Reset configuration options to default values
    def reset!
      Nuorder::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Nuorder::Default.options[key])
      end
      self
    end
    alias setup reset!

    def options
      Hash[Nuorder::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end
