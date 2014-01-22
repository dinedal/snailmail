class Snailmail::TwillioIntegration
  def initialize
    @rest_client =  Twilio::REST::Client.new(Snailmail::TWILLIO_SID, Snailmail::TWILLIO_AUTHTOKEN)

  end

  def twiml
    response = Twilio::TwiML::Response.new do |r|
      yield r
    end
    response.text
  end
end
