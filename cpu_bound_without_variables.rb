require 'digest'

def compute()
  (25 * 50_000).times do
    var = Random.rand(1000)
    result = Digest::SHA512.hexdigest(var.to_s)
  end
  print '.'
end

require 'etc'
MULTIPLY_TASK_NUMBER = Etc.nprocessors / 2 # half of M1 processors are weaker :D

def run_sequential
  MULTIPLY_TASK_NUMBER.times { |x| compute }
end

def run_with_threads
  threads = MULTIPLY_TASK_NUMBER.times.map do
    Thread.new { compute }
  end
  threads.each(&:join)
end

def run_with_processes
  MULTIPLY_TASK_NUMBER.times do
    fork { compute }
  end
  Process.waitall
end

def run_with_ractors
  ractors = MULTIPLY_TASK_NUMBER.times.map do
    Ractor.new { compute }
  end
  ractors.each(&:take)
end

# def ractor
#   r = Ractor.new do
#     # require 'digest'
#     received_message = receive
#     Array(received_message).map do |x|
#       result = x.to_s
#       50_000.times do
#         result = Digest::SHA1.hexdigest(result)
#       end
#     end
#     Ractor.yield 'test'
#     'done'
#   end
#   p r
#   r.send('3', move: true)
#   p r

#   begin
#     p r.take
#   rescue => e
#     p e              #  => #<Ractor::RemoteError: thrown by remote Ractor.>
#     p e.ractor == r  # => true
#     p e.cause        # => #<RuntimeError: Something weird happened>
#     binding.b
#   end
#   p r
# end

# ractor
# exit

# def run_with_ractors
#   puts "\n Running with ractor"
#   ractors = [ractor, ractor, ractor, ractor]
#   (1..100).each_slice(25).with_index do |slice, i|
#     copy = slice.map(&:to_s).dup
#     Ractor.make_shareable(copy)
#     ractors[i].send copy, move: true
#   end
#   # binding.b
#   ractors.each(&:take)
# end
# ERROR: can not access non-shareable objects in constant Kernel::RUBYGEMS_ACTIVATION_MONITOR by non-main ractor. (Ractor::IsolationError)

require './helpers'

Benchmark.benchmark('', nil, FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
  x.report("Ractors \n")  { run_with_ractors }
end