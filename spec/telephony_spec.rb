require './spec/helper.rb'
require 'pry'
class Snailmail::TelephonyTest < MiniTest::Spec

  include Rack::Test::Methods

  before do
  end

  def app
    Snailmail::Telephony
  end

  def test_incoming
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

  def test_user_query
    get '/user_query'
    assert_equal "text/xml;charset=utf-8", last_response.content_type
  end
end
