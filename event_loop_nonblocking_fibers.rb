require 'socket'
require 'async/scheduler'
require './helpers'

def worker(label)
  sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  sock.connect(Socket.sockaddr_in(9000, '127.0.0.1'))
  data = sock.recv(10)
  puts "[Fiber #{label}] Got: #{data}"
  sock.close
end

def run_with_fibers
  Fiber.schedule { worker('#1') }
  Fiber.schedule { worker('#2') }
  Fiber.schedule { worker('#3') }

  Fiber.scheduler.run
end


scheduler = Async::Scheduler.new
Fiber.set_scheduler(scheduler)

measure_duration { run_with_fibers }
