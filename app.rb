require './lib/snailmail'


class Snailmail::App < Sinatra::Base
  @@mailer = Snailmail::LobIntegration.new
  @@phoner = Snailmail::TwillioIntegration.new

  get '/' do
    "hi"
  end

end
