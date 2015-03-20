module Nuorder
  module Default

    # Default API endpoint
    API_ENDPOINT = 'http://buyer.nuorder.com'.freeze

    # If no callback provided the value must be "oob"
    NO_CALLBACK = 'oob'.freeze

    # Default App Name
    APP_NAME = 'Springboard Retail'.freeze

    class << self

      def options
        Hash[Nuorder::Configurable.keys.map { |key| [key, default_value(key)] }]
      end

      def app_name
        APP_NAME
      end

      def api_endpoint
        API_ENDPOINT
      end

      def oauth_callback
        NO_CALLBACK
      end

      private

      # Gets the default value if present or an empty string
      def default_value(key)
        self.respond_to?(key) ? send(key) : ''
      end
    end
  end
end
