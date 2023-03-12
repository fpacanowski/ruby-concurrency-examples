require 'socket'
require './helpers'

def worker(label)
  Fiber.new do
    sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, protocol = 0)
    sock.connect(Socket.sockaddr_in(9000, '127.0.0.1'))
    loop do
      data = sock.recv_nonblock(10, exception: false)
      if data != :wait_readable
        puts "[Fiber #{label}] Got: #{data}"
        break
      end
      Fiber.yield
    end
    sock.close
  end
end

def run_with_fibers
  workers = [] <<
    worker('#1')
    worker('#2')
    worker('#3')

  while workers.any?(&:alive?)
    workers.each(&:resume)
    sleep 0.01
  end
end

measure_duration { run_with_fibers }
