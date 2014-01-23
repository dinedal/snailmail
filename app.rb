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
      r.Gather :action => 'user_query', :method => 'get' do
        r.Say 'Please enter your user short code
               followed by the pound sign', :voice => 'alice'
      end
      r.Say 'Goodbye', :voice => 'alice'
    end
  end

  post '/user_query' do
    content_type 'text/xml'
    user = User.with(:short_code, params['Digits'])
    if user
      choices = user.recipients.map{|r| [r.name, r.short_code]}.join(', ')
      r.Gather :action => 'record_for_recipient', :method => 'get' do
        r.Say 'Please pick a recipient followed by the pound sign.
               Your choices are, ' + choices, :voice => 'alice'
      end
    else
      r.Say 'No user find. Goodbye', :voice => 'alice'
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
