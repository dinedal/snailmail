require './app'
run Rack::URLMap.new({
    "/" => Snailmail::Web,
    "/telephony" => Snailmail::Telephony,
  })
