require "net/http"

def fetch_random
  response_body = Net::HTTP.get('127.0.0.1', '/', port = 4567)
  # puts "Got: #{response_body}"
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

def run_with_ractors
  ractors = 3.times.map do
    Ractor.new { fetch_random }
  end
  ractors.each(&:take)
end
# DOES NOT WORK

require './helpers'

Benchmark.benchmark('', nil, FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
  # x.report("Ractors \n")  { run_with_ractors }
end