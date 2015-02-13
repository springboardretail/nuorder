SENSITIVE_DATA = %w(
  OAUTH_CONSUMER_KEY
  OAUTH_CONSUMER_SECRET
  OAUTH_TOKEN
  OAUTH_TOKEN_SECRET
)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :excon
  config.configure_rspec_metadata!
  
  SENSITIVE_DATA.each do |key|
    config.filter_sensitive_data(key) { ENV[key] }
  end
end
