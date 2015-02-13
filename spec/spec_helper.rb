require 'nuorder'
require 'byebug'
require 'vcr'
require 'dotenv'

Dotenv.load

Dir['./spec/support/**/*.rb'].each { |f| require f }
