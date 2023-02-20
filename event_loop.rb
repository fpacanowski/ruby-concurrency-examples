require 'socket'
require './helpers'

class Worker
  def initialize(label)
    @label = label
    @state = :started
  end

  def tick
    # puts "Worker #{@label} state: #{@state.inspect}"
    case @state
    when :started
      @sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      @sock.connect(Socket.sockaddr_in(9000, '127.0.0.1'))
      @state = :waiting_for_data
    when :waiting_for_data
      data = @sock.recv_nonblock(10, exception: false)
      if data != :wait_readable
        puts "[Worker #{@label}] Got: #{data}"
        @state = :finished
      end
    end
  end

  def in_progress?
    @state != :finished
  end
end

def run_with_reactor
  workers = []
  workers << Worker.new('#1')
  workers << Worker.new('#2')
  workers << Worker.new('#3')

  while workers.any?(&:in_progress?)
    workers.each(&:tick)
    sleep 0.01
  end
end

measure_duration { run_with_reactor }
