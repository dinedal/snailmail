require './spec/helper.rb'
require 'pry'

def app
  Snailmail::Telephony
end


describe 'Twillio UI Flow' do
  before do
    Ohm.conn.threaded.each{|_,r| r.flushdb if r}
  end

  it 'asks new callers for thier shortcode' do
    post '/incoming'
    assert last_response.ok?
    assert_equal "text/xml;charset=utf-8", last_response.content_type

    response_body = Twilio::TwiML::Response.new do |r|
      r.Gather :action => 'user_query', :method => 'get' do
        r.Say 'Please enter your user short code
               followed by the pound sign', :voice => 'alice'
      end
      r.Say 'Goodbye', :voice => 'alice'
    end

    assert_equal response_body.text, last_response.body
  end

  describe 'User recipient querying' do

    it 'replies correctly when there is no user found' do
      get '/user_query'
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type

      response_body = Twilio::TwiML::Response.new do |r|
        r.Say 'No user found. Goodbye', :voice => 'alice'
      end

      assert_equal response_body.text, last_response.body
    end

    it 'replies correctly when there are no uses' do
      get '/user_query', :Digits => user_no_uses.short_code
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type

      response_body = Twilio::TwiML::Response.new do |r|
        r.Say "No uses remain for #{user_no_uses.name}. Goodbye", :voice => 'alice'
      end

      assert_equal response_body.text, last_response.body
    end

    it 'replies correctly when there are no recipients' do
      get '/user_query', :Digits => user_no_recipients.short_code
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type

      response_body = Twilio::TwiML::Response.new do |r|
        r.Say "No recipients found for #{user_no_recipients.name}. Goodbye", :voice => 'alice'
      end

      assert_equal response_body.text, last_response.body
    end

    it 'lists recipients in a menu for users with uses and recipients' do
      get '/user_query', :Digits => user_with_recipient.short_code
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type

      choices = user_with_recipient.recipients.map{|r| [r.name, r.short_code]}.join(', ')
      response_body = Twilio::TwiML::Response.new do |r|
        r.Gather :action => 'record_for_recipient', :method => 'get' do
          r.Say 'Please pick a recipient followed by the pound sign.
                 Your choices are, ' + choices, :voice => 'alice'
        end
      end

      assert_equal response_body.text, last_response.body
    end
  end

  describe 'Recording message and generating post card' do
    it 'prompts the user for a recording when none is present' do
      get '/record_for_recipient', {
        :Digits => recipient.short_code,
        :CallSid => SecureRandom.uuid,
      }
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type

      response_body = Twilio::TwiML::Response.new do |r|
        r.Say "Record your post card for #{recipient.name} after the tone", :voice => 'alice'
        r.Record :timeout => 14, :method => 'get'
      end

      assert_equal response_body.text, last_response.body
    end

    it 'properly transcribes a recording, and generates a postcard' do
      call_sid = SecureRandom.uuid
      recording_url = "http://recording.gov/"
      transcription = "Testing the route"
      Ohm.redis.hset("current_calls", call_sid, recipient.id)

      current_uses_remaining = recipient.user.uses_remaining

      Snailmail::Transcription.
        expects(:wav_to_text).
        with(recording_url).
        returns(transcription)

      Snailmail::LobIntegration.expects(:mail_postcard).
        with(
        recipient.address_to_hash,
        recipient.user.address_to_hash,
        "http://#{Snailmail::SITE_HOSTNAME}/random_postcard",
        transcription).
        returns(true)

      get '/record_for_recipient', {
        :CallSid => call_sid,
        :RecordingUrl => recording_url,
      }

      assert Ohm.redis.hget("current_calls", call_sid).nil?, true
      assert (current_uses_remaining - 1), recipient.user.uses_remaining
      assert last_response.ok?
      assert_equal "text/xml;charset=utf-8", last_response.content_type
    end
  end

end
