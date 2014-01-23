require './lib/snailmail'


class Snailmail::Web < Sinatra::Base
  @@mailer = Snailmail::LobIntegration.new

  get '/' do
    "hi"
  end

end

class Snailmail::Telephony < Sinatra::Base
  @@phoner = Snailmail::TwillioIntegration.new

  post '/incoming' do
    content_type 'text/xml'
    @@phoner.twiml do |r|
      r.Say 'hello there', :voice => 'alice'
    end
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
