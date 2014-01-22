require './lib/snailmail'


class Snailmail::App < Sinatra::Base
  get '/' do
    "hi"
  end
end

Snailmail::App.run!
