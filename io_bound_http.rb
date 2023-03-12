require "net/http"
require 'debug'
require './helpers'

def fetch_random
  response_body = Net::HTTP.get('127.0.0.1', '/', port = 4567)
  puts "Got: #{response_body}"
end

def run_sequential
  puts "\n Running sequential"
  3.times { fetch_random }
end

def run_with_threads
  puts "\n Running with threads"
  threads = []
  3.times do
    threads << Thread.new { fetch_random }
  end
  threads.each(&:join)
end

def run_with_processes
  puts "\n Running with processes"
  3.times do
    fork { fetch_random }
  end
  Process.waitall
end

measure_duration { run_sequential }

measure_duration { run_with_threads }

measure_duration { run_with_processes }
