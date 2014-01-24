require './lib/snailmail'

class Snailmail::Web < Sinatra::Base
  POSTCARD_IMAGES = `ls ./assets/postcard_images/`.split("\n")
  set :public_folder, 'assets'

  get '/' do
    "hi"
  end

  get '/random_postcard' do
    send_file File.join(settings.public_folder, 'postcard_images/', POSTCARD_IMAGES.shuffle.first)
  end

end

class Snailmail::Telephony < Sinatra::Base
  @@phoner = Snailmail::TwillioIntegration.new
  @@mailer = Snailmail::LobIntegration.new
  @@current_calls = {}

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

    if params['RecordingUrl'] && @@current_calls[params['CallSid']]
      # We have a recording coming in, and a matching on-going call
      recipient = Recipient[@@current_calls.delete(params['CallSid'])]
      $stderr.puts "---------------------------------------"
      $stderr.puts "#{params['RecordingUrl']}"
      $stderr.puts "---------------------------------------"
      @@phoner.twiml do |r|
        r.Hangup
      end
    elsif @@current_calls[params['CallSid']] == nil
      recipient = Recipient.with(:short_code, params['Digits'])
      @@current_calls[params['CallSid']] = recipient.id
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

  # GOLD
  # curl http://api.twilio.com/2010-04-01/Accounts/ACb84633f66d5af69d5d09b9b6535f1ed7/Recordings/RE6ff45ca6335a9b32a060fc997987f93e 2> /dev/null | ffmpeg -i pipe:0 -vn -sn -acodec flac -f flac pipe:1 | curl -v -X POST -H 'Content-Type: audio/x-flac; rate=8000' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7' --data-binary @- https://www.google.com/speech-api/v1/recognize\?xjerr\=1\&client\=chromium\&lang\=en-US\&results\=10
  # Ruby
  # %x{curl http://api.twilio.com/2010-04-01/Accounts/ACb84633f66d5af69d5d09b9b6535f1ed7/Recordings/RE6ff45ca6335a9b32a060fc997987f93e 2> /dev/null | ffmpeg -i pipe:0 -vn -sn -acodec flac -f flac pipe:1 | curl -v -X POST -H 'Content-Type: audio/x-flac; rate=8000' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7' --data-binary @- "https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US&results=10"}
  #
  # After
  # {"status"=>0,
  # "id"=>"",
  # "hypotheses"=>
  #  [{"utterance"=>"hello this is Paul trying out the recording service",
  #    "confidence"=>0.94003147}]}
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
