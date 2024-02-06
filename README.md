# NuORDER

[![Gem Version](https://badge.fury.io/rb/nuorder.svg)](http://badge.fury.io/rb/nuorder)
[![Build](https://github.com/springboardretail/nuorder/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/springboardretail/nuorder/actions/workflows/build.yml)

Gem that wraps up the communication with the API services from [NuORDER](http://www.nuorder.com/)

[Faraday](https://github.com/lostisland/faraday) and [Excon](https://github.com/excon/excon) are used for creating persistent connections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nuorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nuorder

## Usage

### Configuration

The following options are available when configuring NuORDER:

1. `app_name` Default: `'Springboard Retail'`
2. `api_endpoint` Default: `'http://buyer.nuorder.com'`
3. `oauth_consumer_key`
4. `oauth_consumer_secret`
5. `oauth_token`
6. `oauth_token_secret`
7. `oauth_callback` Default: `'oob'`
    * NuORDER will POST the callback the `oauth_verifier` token.
    * If the callback is set to `'oob'`, the `oauth_verifier` token must be supplied manually by the user.

#### Example

```ruby
Nuorder.configure do |config|
  config.oauth_consumer_key = 'key'
  config.oauth_consumer_secret = 'key'
  config.oauth_token = 'key'
  config.oauth_token_secret = 'key'
end
````

or

```
client = Nuorder::Client.new(oauth_token: 'key', oauth_token_secret: 'key')
```

### Authorization (OAuth 1.0)

NuORDER uses OAuth 1.0 for authorization.

To get the oauth tokens the following methods must be called:

1. `Nuorder.api_initiate`
  * An inital call will be made in order to get the temporary tokens.
2. `Nuorder.get_oauth_token(oauth_verifier)`
  * Call for getting the permanent tokens.
  * `oauth_verifier` must be supplied.

Retrieve tokens:

```ruby
oauth_token = Nuorder.oauth_token
oauth_token_secret = Nuorder.oauth_token_secret
```

### Requests
TODO

## Contributing

1. Fork it ( https://github.com/springboardretail/nuorder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Running tests

Place your consumer keys and tokens in the `.env` file

```
OAUTH_CONSUMER_KEY = 'nuorder-consumer-key'
OAUTH_CONSUMER_SECRET = 'nuorder-consumer-secret'
OAUTH_TOKEN = 'nuorder-oauth-token'
OAUTH_TOKEN_SECRET = 'nuorder-token-secret'
```

`rake` default task will run all the tests
