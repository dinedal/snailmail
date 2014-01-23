require 'dotenv'
Dotenv.load

module Snailmail
  LOB_APIKEY        = ENV['LOB_APIKEY']
  TWILLIO_SID       = ENV['TWILLIO_SID']
  TWILLIO_AUTHTOKEN = ENV['TWILLIO_AUTHTOKEN']
  ADMIN_PASSWORD    = ENV['ADMIN_PASSWORD']
  REDIS_URL         = ENV['REDISTOGO_URL']
end

require 'sinatra/base'
require 'lob'
require 'twilio-ruby'
require 'redic'
require 'ohm'

Ohm.redis = Redic.new(Snailmail::REDIS_URL)

Dir["./lib/snailmail/**"].map(&method(:require))
