require './lib/snailmail'


class Snailmail::Web < Sinatra::Base
  @@mailer = Snailmail::LobIntegration.new
  @@phoner = Snailmail::TwillioIntegration.new

  get '/' do
    "hi"
  end

end

class Snailmail::Telephony < Sinatra::Base

  post '/incoming' do
    "run run"
  end
end

class Snailmail::AdminApi < Sinatra::Base

  get '/' do
    "secert"
  end

  def self.new(*)
    app = Rack::Auth::Digest::MD5.new(super) do |username|
      {'admin' => Snailmail::ADMIN_PASSWORD}[username]
    end
    app.realm = 'Protected Area'
    app.opaque = 'secretkey'
    app
  end

end
