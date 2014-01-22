require './lib/snailmail'


class SnailMailApp < Sinatra::Base
  get '/' do
    "hi"
  end
end

SnailMailApp.run!
