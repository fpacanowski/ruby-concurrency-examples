require 'sinatra'

get '/' do
  sleep 2
  Random.rand(10).to_s
end