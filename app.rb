require './lib/snailmail'

class Snailmail::Web < Sinatra::Base
  POSTCARD_IMAGES = `ls ./assets/postcard_images/`.split("\n")
  set :public_folder, 'assets'

  get '/random_postcard' do
    last_modified(Time.now - 10)
    send_file File.join(settings.public_folder, 'postcard_images/', POSTCARD_IMAGES.shuffle.first)
  end

end

class Snailmail::Telephony < Sinatra::Base

  post '/incoming' do
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      r.Gather :action => 'user_query', :method => 'get' do
        r.Say 'Please enter your user short code
               followed by the pound sign', :voice => 'alice'
      end
      r.Say 'Goodbye', :voice => 'alice'
    end.text
  end

  get '/user_query' do
    content_type 'text/xml'
    user = User.with(:short_code, params['Digits'])
    if user && !user.recipients.empty? && (user.uses_remaining > 0)
      choices = user.recipients.map{|r| [r.name, r.short_code]}.join(', ')
      Twilio::TwiML::Response.new do |r|
        r.Gather :action => 'record_for_recipient', :method => 'get' do
          r.Say 'Please pick a recipient followed by the pound sign.
                 Your choices are, ' + choices, :voice => 'alice'
        end
      end.text
    elsif user && user.uses_remaining <= 0
      Twilio::TwiML::Response.new do |r|
        r.Say "No uses remain for #{user.name}. Goodbye", :voice => 'alice'
      end.text
    elsif user
      Twilio::TwiML::Response.new do |r|
        r.Say "No recipients found for #{user.name}. Goodbye", :voice => 'alice'
      end.text
    else
      Twilio::TwiML::Response.new do |r|
        r.Say 'No user found. Goodbye', :voice => 'alice'
      end.text
    end
  end

  get '/record_for_recipient' do
    content_type 'text/xml'

    redis = Ohm.redis

    if params['RecordingUrl'] &&
        (r_id = redis.hget("current_calls", params['CallSid']))
      # We have a recording coming in, and a matching on-going call
      recipient = Recipient[r_id.to_i]
      redis.hdel("current_calls", params['CallSid'])
      user = recipient.user

      message = Snailmail::Transcription.wav_to_text(params['RecordingUrl'])

      postcard_result = Snailmail::LobIntegration.mail_postcard(
        recipient.address_to_hash,
        user.address_to_hash,
        "http://#{Snailmail::SITE_HOSTNAME}/random_postcard",
        message
      )

      user.decr(:uses_remaining)

      if Snailmail::EMAIL_ENABLED
        Pony.mail(
          :subject => "Snailmail used by User #{user.name}",
          :body    => %Q{
User ID / Name: #{user.id} / #{user.name}
Recipient ID: #{recipient.id} / #{recipient.name}
Generated postcard #{postcard_result["url"]}
})
      end

      Twilio::TwiML::Response.new do |r|
        r.Hangup
      end.text
    elsif redis.hget("current_calls", params['CallSid']).nil?
      recipient = Recipient.with(:short_code, params['Digits'])
      redis.hset("current_calls", params['CallSid'], recipient.id)

      Twilio::TwiML::Response.new do |r|
        r.Say "Record your post card for #{recipient.name} after the tone", :voice => 'alice'
        r.Record :timeout => 14, :method => 'get'
      end.text
    else
      redis.hdel("current_calls", params['CallSid'])
      Twilio::TwiML::Response.new do |r|
        r.Say "There was a problem, please try your call again", :voice => 'alice'
      end.text
    end
  end

end
