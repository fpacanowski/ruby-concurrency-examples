require 'digest'

def compute(input)
  result = input.to_s
  50_000.times do
    result = Digest::SHA1.hexdigest(result)
  end
end

def run_sequential
  puts 'Running sequential'
  (1..100).map { |x| compute(x) } 
end

def run_with_threads
  puts 'Running with threads'
  threads = []
  (1..100).each_slice(25) do |slice|
    threads << Thread.new { slice.map { |x| compute(x) } }
  end
  threads.each(&:join)
end

def run_with_processes
  puts 'Running with processes'
  (1..100).each_slice(25) do |slice|
    fork { slice.map { |x| compute(x) } }
  end
  Process.waitall
end

def measure_duration
  start = Time.now
  yield
  puts "Duration: #{Time.now - start}"
end

measure_duration { run_sequential }
puts

measure_duration { run_with_threads }
puts

measure_duration { run_with_processes }
puts
