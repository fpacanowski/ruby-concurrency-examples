require 'async'
require 'async/barrier'
require 'async/http/internet'
require "net/http"
require 'httpray'

def fetch_random
  response_body = Net::HTTP.get('127.0.0.1', '/', port = 4567)
  puts "Got: #{response_body}"
end

def run_sequential
  3.times { fetch_random }
end

def run_with_threads
  threads = 3.times.map do
    Thread.new { fetch_random }
  end
  threads.each(&:join)
end

def run_with_processes
  3.times do
    fork { fetch_random }
  end
  Process.waitall
end

def run_with_async
  Async do |task|
    internet = Async::HTTP::Internet.new

    # Issues a POST request:
    3.times do
      task.async do
        response = internet.get('http://127.0.0.1:4567/')
        puts "Got: #{response.body.read}"
      end
    end
  ensure
    # The internet is closed for business:
    internet.close
  end
end

# does not work within ractor
def fetch_random_async
  # Async do |task|
    internet = Async::HTTP::Internet.new
    # task.async do
      response = internet.get('http://127.0.0.1:4567/')
      # puts "Got: #{response.body.read}"
    # end
  # ensure
    # The internet is closed for business:
    internet.close
  # end
end

def run_with_ractors
  ractors = 3.times.map do
    Ractor.new do
      # HTTPray non blocking GETs
      HTTPray.request("GET", "http://127.0.0.1:4567/") do |socket|
        puts "Got: #{socket.gets}"
      end
    end
  end
  ractors.each(&:take)
end
# DOES NOT WORK

require './helpers'

Benchmark.benchmark('', nil, FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
  x.report("Async \n")  { run_with_async }
  # x.report("Ractors \n")  { run_with_ractors }
end