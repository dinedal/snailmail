require './app'
run Rack::URLMap.new({
    "/" => Snailmail::Web,
    "/protected" => Snailmail::AdminApi,
    "/telephony" => Snailmail::Telephony,
  })
