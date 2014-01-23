require 'dotenv'
Dotenv.load

module Snailmail
  LOB_APIKEY        = ENV['LOB_APIKEY']
  TWILLIO_SID       = ENV['TWILLIO_SID']
  TWILLIO_AUTHTOKEN = ENV['TWILLIO_AUTHTOKEN']
  ADMIN_PASSWORD    = ENV['ADMIN_PASSWORD']
end

require 'sinatra/base'
require 'lob'
require 'twilio-ruby'

Dir["./lib/snailmail/**"].map(&method(:require))
