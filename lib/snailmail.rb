require 'dotenv'
Dotenv.load

module Snailmail
  LOB_APIKEY        = ENV['LOB_APIKEY']
  ADMIN_PASSWORD    = ENV['ADMIN_PASSWORD']
  REDIS_URL         = ENV['REDISTOGO_URL']
  SITE_HOSTNAME     = ENV['SITE_HOSTNAME']
end

require 'sinatra/base'
require 'lob'
require 'twilio-ruby'
require 'redic'
require 'ohm'

Ohm.connect(url: Snailmail::REDIS_URL)

Dir["./lib/snailmail/**"].map(&method(:require))
