require './lib/snailmail'

class Snailmail::Web < Sinatra::Base
  POSTCARD_IMAGES = `ls ./assets/postcard_images/`.split("\n")
  set :public_folder, 'assets'

  get '/' do
    ""
  end

  get '/random_postcard' do
    last_modified(Time.now - 10)
    send_file File.join(settings.public_folder, 'postcard_images/', POSTCARD_IMAGES.shuffle.first)
  end

end

class Snailmail::Telephony < Sinatra::Base
  @@phoner = Snailmail::TwillioIntegration.new
  @@mailer = Snailmail::LobIntegration.new

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

  get '/user_query' do
    content_type 'text/xml'
    user = User.with(:short_code, params['Digits'])
    if user && !user.recipients.empty?
      choices = user.recipients.map{|r| [r.name, r.short_code]}.join(', ')
      @@phoner.twiml do |r|
        r.Gather :action => 'record_for_recipient', :method => 'get' do
          r.Say 'Please pick a recipient followed by the pound sign.
                 Your choices are, ' + choices, :voice => 'alice'
        end
      end
    elsif user
      @@phoner.twiml do |r|
        r.Say "No recipients found for #{user.name}. Goodbye", :voice => 'alice'
      end
    else
      @@phoner.twiml do |r|
        r.Say 'No user found. Goodbye', :voice => 'alice'
      end
    end
  end

  get '/record_for_recipient' do
    content_type 'text/xml'

    redis = Ohm.redis

    if params['RecordingUrl'] &&
        (r_id = redis.hget("current_calls", current_calls[params['CallSid']]))
      # We have a recording coming in, and a matching on-going call
      recipient = Recipient[r_id.to_i]
      redis.hdel("current_calls", current_calls[params['CallSid']])
      user = recipient.user
      $stderr.puts "---------------------------------------"
      $stderr.puts "#{params['RecordingUrl']}"
      $stderr.puts "---------------------------------------"

      message = Snailmail::Transcription.wav_to_text(params['RecordingUrl'])

      $stderr.puts "---------------------------------------"
      $stderr.puts message
      $stderr.puts "---------------------------------------"

      @@mailer.mail_postcard(
        recipient.address_to_hash,
        user.address_to_hash,
        "http://#{Snailmail::SITE_HOSTNAME}/random_postcard",
        message
      )

      @@phoner.twiml do |r|
        r.Hangup
      end
    elsif @@current_calls[params['CallSid']] == nil
      recipient = Recipient.with(:short_code, params['Digits'])
      redis.hset("current_calls", params['CallSid'], recipient.id)

      @@phoner.twiml do |r|
        r.Say "Record your post card for #{recipient.name} after the tone", :voice => 'alice'
        r.Record :timeout => 14, :method => 'get'
      end
    else
      @@phoner.twiml do |r|
        r.Say "There was a problem, please try your call again", :voice => 'alice'
      end
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
