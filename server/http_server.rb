require 'sinatra'

configure do
  set :server, :falcon
end

get '/' do
  sleep 2
  Random.rand(100).to_s
end