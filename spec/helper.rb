ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/pride'
require 'mock_redis'
require 'rack/test'
require 'minitest/spec'
require './app.rb'

# Mock redis connection per model
Ohm.conn.threaded["User"] = MockRedis.new
Ohm.conn.threaded["Recipient"] = MockRedis.new
