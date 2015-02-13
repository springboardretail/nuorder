config_hash = {
  oauth_consumer_key: ENV['OAUTH_CONSUMER_KEY'],
  oauth_consumer_secret: ENV['OAUTH_CONSUMER_SECRET'],
  oauth_token: ENV['OAUTH_TOKEN'],
  oauth_token_secret: ENV['OAUTH_TOKEN_SECRET']
}

shared_examples 'config hash' do
  let!(:config) { config_hash }
end
