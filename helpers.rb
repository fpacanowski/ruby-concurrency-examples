def measure_duration
  start = Time.now
  yield
  puts "Duration: #{Time.now - start}"
end
