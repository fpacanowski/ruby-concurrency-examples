# Ruby asynchronous, tribute to fibers in ruby 3.0

This ruby repository explores asynchronous programming with a focus on fibers in Ruby 3.0.

The project explores both CPU-bound tasks with parallelism and I/O-bound tasks with concurrency/parallelism, using examples of TCP socket communication and HTTP requests. The file provides instructions for running the necessary servers and clients to test these scenarios.

The readme also introduces the concept of async programming with fibers, explaining the difference between blocking and non-blocking operations and the use of fibers for implementing enumerators. It provides examples of using fibers to handle I/O states in workers and how fibers can automatically switch from blocking to non-blocking using a scheduler object.

The file includes code examples for each concept discussed and provides clear instructions for running the code.

## How to run

start with installing required gems with `bundle install`

## CPU bound tasks with paralelism

`ruby cpu_bound.rb`

## I/O bound tasks with concurrency / paralelism

### TCP socket communication

run TCP socket server, returning random number after 2 second delay:

`ruby server/socket_server.rb`  or node js version `node server/server.js`

(jump into new terminal tab)

now we will compare sending request to socket server using solutions, which were used in previous chapter

`ruby io_bound.rb`

### HTTP requests

Similar case is http server request.
To test it out run http server, which returns random number after 2 seconds

`ruby server/http_server.rb`

(jump into new terminal tab)

now we will compare sending request to http server using solutions, which were used in previous chapter.
Unfortunatelly ractors does not support making http requests inside them with standard NET::HTTP. So we added httpray gem to send http non-blocking requests.

`ruby io_bound_http.rb`

## Introduction to async gem, so Fibers

### Blocking operation vs non-blocking

With I/O we wait mostly for (HTTP/SQL TCP) response. We don't have to block execution of current thread, but manage it by our own (non-blocking way)

Let's try writing our own non-blocking solution with `socket.recv_nonblock`
In loop we will wait until all 3 workers will return our random number then finish our execution.

`ruby event_loop.rb`

Every 0.01s we get socket result until we finish our workers tasks

### What is Fiber

They implement enumerators, here is fibonnaci implementation example:

`ruby fibers_example.rb`

Ractors remember state and freeze until we `.resume` them again

### Fiber for I/O

Instead of handling socket states in worker instances, we can use Fiber concept.
Lets freeze (using `Fiber.yield`) until next `.resume` until we receive data from socket.

`ruby event_loop_fibers`

Again every 0.01s we will check if Fibers are still `.alive?`

### Fiber auto-switch from blocking to non-blocking (from ruby 3.0)

Fibers provides more, better experience for non blocking I/O.

We can provide scheduler object to implement: how often should we `.resume` our fibers with global setup:

`Fiber.set_scheduler(scheduler)`

Then we can `.schedule` our workers and write them in the way like they would block the execution on receive.

Code within `Fiber.schedule` will automatically switch from `socket.recv` to `socket.recv_nonblock`, so we will gain whole non-blocking magic by understanding just how to setup scheduler for fibers.
