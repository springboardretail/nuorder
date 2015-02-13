# Nuorder

Gem that wraps up the communication with the API services from [Nuorder](http://www.nuorder.com/)

[Faraday](https://github.com/lostisland/faraday) and [Excon](https://github.com/excon/excon) are used for creating permanent connections.

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

### Initialization

To create a new `Connector` you must pass the following variables:

1. `app_name`
2. `base_uri`
3. `config` hash. You must indicate the following keys:
  * `oauth_consumer_key`
  * `oauth_consumer_secret`
  * `oauth_token`
  * `oauth_token_secret`
  * `oauth_callback` If none it will be set to `'oob'`
    * Nuorder will POST the callback the `oauth_verifier` token.
    * If the callback is set to `'oob'`, the `oauth_verifier` token must be supplied manually by the user. 

#### Example

```ruby
config = {
  oauth_consumer_key: 'key',
  oauth_consumer_secret: 'key',
  oauth_token: 'key',
  oauth_token_secret: 'key',
  oauth_callback: 'myapp.example.com/callback' 
}

Nuorder::Connector.new('my-app', 'http://buyer.sandbox1.nuorder.com', config)
```

### Authorization (OAuth 1.0)

Nuorder uses OAuth 1.0 for authorization.

To get the oauth tokens the following methods must be called:

1. `connector.api_initiate`
  * An inital call will be made in order to get the temporary tokens.
2. `connector.get_oauth_token(oauth_verifier)`
  * Call for getting the permanent tokens.
  * `oauth_verifier` must be supplied. 

Retrieve tokens:

```ruby
oauth_token = connector.oauth.token
oauth_token_secret = connector.oauth.token_secret
```

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
