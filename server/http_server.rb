require 'sinatra'

get '/' do
  sleep 2
  Random.rand(100).to_s
end