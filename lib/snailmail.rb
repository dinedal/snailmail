require 'dotenv'
Dotenv.load

module Snailmail
  LOB_APIKEY        = ENV['LOB_APIKEY']
  REDIS_URL         = ENV['REDIS_URL'] || ENV['REDISTOGO_URL']
  SITE_HOSTNAME     = ENV['SITE_HOSTNAME']
  SENDGRID_PASSWORD = ENV['SENDGRID_PASSWORD']
  SENDGRID_USERNAME = ENV['SENDGRID_USERNAME']
  ADMIN_EMAIL       = ENV['ADMIN_EMAIL']
end

require 'sinatra/base'
require 'lob'
require 'twilio-ruby'
require 'redic'
require 'ohm'

Ohm.connect(url: Snailmail::REDIS_URL)

Dir["./lib/snailmail/**"].map(&method(:require))
