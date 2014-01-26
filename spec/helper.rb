ENV['RACK_ENV'] = 'test'
require 'securerandom'
require 'minitest/autorun'
require 'minitest/pride'
require 'mock_redis'
require 'rack/test'
require 'minitest/spec'
require 'mocha/mini_test'
require './app.rb'

# Mock redis connection per model
Ohm.redis
Ohm.conn.threaded[:main] = MockRedis.new
Ohm.conn.threaded["User"] = MockRedis.new
Ohm.conn.threaded["Recipient"] = MockRedis.new

require './spec/mocks.rb'

include Rack::Test::Methods
include Snailmail::Mocks
