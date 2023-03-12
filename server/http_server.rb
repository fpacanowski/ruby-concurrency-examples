require 'sinatra'

get '/' do
  sleep 2
  (0..9).to_a.sample.to_s
end