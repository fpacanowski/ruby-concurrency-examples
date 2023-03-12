require 'socket'
require './helpers'

def fetch_random
  sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, protocol = 0)
  # sock.connect(Socket.sockaddr_in(9000, '127.0.0.1')) # eq to next line
  sock.connect Socket.pack_sockaddr_in(9000, '127.0.0.1')
  data = sock.recv(10)
  puts "Got: #{data}"
  sock.close
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
