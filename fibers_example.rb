fibonacci = Fiber.new do
  a = 0
  b = 1
  loop do
    a, b = b, a+b
    Fiber.yield a
  end
end

10.times { puts fibonacci.resume }
