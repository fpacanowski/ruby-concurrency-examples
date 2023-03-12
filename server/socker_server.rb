# from https://scoutapm.com/blog/ruby-ractor
require 'socket'

# The requests' queue
queue = Ractor.new do
    loop do
        Ractor.yield(Ractor.recv, move: true)
    end
end

# Number of running workers
COUNT = 8

# Worker ractors
workers = COUNT.times.map do
    Ractor.new(queue) do |queue|
        loop do
            session = queue.take
            data = session.recv(1024)
            puts data
            session.print "Hello world!\n"
            session.close
        end
    end
end

# TCP server instance
server = TCPServer.new(8000)
loop do
    conn, _ = server.accept
    queue.send(conn, move: true)
end