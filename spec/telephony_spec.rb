require './spec/helper.rb'

def app
  Snailmail::Telephony
end

include Rack::Test::Methods


describe 'Twillio UI Flow' do

  it 'asks new callers for thier shortcode' do
    post '/incoming'
    assert last_response.ok?

    response_body = Twilio::TwiML::Response.new do |r|
      r.Gather :action => 'user_query', :method => 'get' do
        r.Say 'Please enter your user short code
               followed by the pound sign', :voice => 'alice'
      end
      r.Say 'Goodbye', :voice => 'alice'
    end

    assert_equal response_body.text, last_response.body
    assert_equal "text/xml;charset=utf-8", last_response.content_type
  end


end
