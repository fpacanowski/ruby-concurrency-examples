require 'socket'

def fetch_random
  sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, protocol = 0)
  sock.connect Socket.pack_sockaddr_in(9000, '127.0.0.1')
  data = sock.recv(10)
  puts "Got: #{data}"
  sock.close
end

def run_sequential
  3.times { fetch_random }
end

def run_with_threads
  threads = []
  3.times do
    threads << Thread.new { fetch_random }
  end
  threads.each(&:join)
end

def run_with_processes
  3.times do
    fork { fetch_random }
  end
  Process.waitall
end

require './helpers'

Benchmark.benchmark('', nil, FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
end
