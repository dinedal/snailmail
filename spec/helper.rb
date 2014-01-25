ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/pride'
require 'mock_redis'
require 'rack/test'

require './app.rb'

Ohm.conn.threaded["User"] = MockRedis.new
Ohm.conn.threaded["Recipient"] = MockRedis.new
