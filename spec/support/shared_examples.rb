options = {
  app_name: 'TEST APP',
  api_endpoint: 'http://buyer.sandbox1.nuorder.com',
  oauth_consumer_key: ENV['OAUTH_CONSUMER_KEY'],
  oauth_consumer_secret: ENV['OAUTH_CONSUMER_SECRET'],
  oauth_token: ENV['OAUTH_TOKEN'],
  oauth_token_secret: ENV['OAUTH_TOKEN_SECRET']
}

shared_examples 'options client' do
  let!(:options_client) { options }
end
