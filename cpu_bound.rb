require 'digest'
require './helpers'
require 'debug'

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

def run_with_ractors_wrong
  puts 'Running with ractor'
  ractors = []
  (1..100).each_slice(25) do |slice|
    slice.dup.then do |tmp|
      Ractor.make_shareable(tmp)
      ractors << Ractor.new(tmp) { |param| param.map { |x| compute(x) } }
    end
  end
  ractors.each(&:take)
end

def ractor
  r = Ractor.new do
    # require 'digest'
    received_message = receive
    Array(received_message).map do |x|
      result = x.to_s
      50_000.times do
        result = Digest::SHA1.hexdigest(result)
      end
    end
    Ractor.yield 'test'
    'done'
  end
  p r
  r.send('3', move: true)
  p r

  begin
    p r.take
  rescue => e
    p e              #  => #<Ractor::RemoteError: thrown by remote Ractor.>
    p e.ractor == r  # => true
    p e.cause        # => #<RuntimeError: Something weird happened>
    binding.b
  end
  p r
end

# ractor
# exit

def run_with_ractors
  puts 'Running with ractor'
  ractors = [ractor, ractor, ractor, ractor]
  (1..100).each_slice(25).with_index do |slice, i|
    copy = slice.map(&:to_s).dup
    Ractor.make_shareable(copy)
    ractors[i].send copy, move: true
  end
  # binding.b
  ractors.each(&:take)
end
# ERROR: can not access non-shareable objects in constant Kernel::RUBYGEMS_ACTIVATION_MONITOR by non-main ractor. (Ractor::IsolationError)

measure_duration { p run_sequential }
puts

measure_duration { p run_with_threads }
puts

measure_duration { p run_with_processes }
puts

# measure_duration { p run_with_ractors }
puts
