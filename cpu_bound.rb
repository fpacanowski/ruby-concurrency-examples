require 'digest'

def compute(input)
  result = input.to_s
  50_000.times do
    result = Digest::SHA1.hexdigest(result)
  end
  print '.'
end

def run_sequential
  (1..100).map { |x| compute(x) }
end

def run_with_threads
  threads = (1..100).each_slice(25).map do |slice|
    Thread.new { slice.map { |x| compute(x) } }
  end
  threads.each(&:join)
end

def run_with_processes
  (1..100).each_slice(25) do |slice|
    fork { slice.map { |x| compute(x) } }
  end
  Process.waitall
end

def run_with_ractors_wrong
  ractors = (1..100).each_slice(25).map do |slice|
    slice.dup.then do |tmp|
      Ractor.make_shareable(tmp)
      Ractor.new(tmp) { |param| param.map { |x| compute(x) } }
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

require './helpers'

Benchmark.benchmark('', nil, "\n" + FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
  # x.report("Ractors \n")  { run_with_ractors }
end