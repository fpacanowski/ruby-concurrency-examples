require 'digest'
require './helpers'
require 'debug'
require 'securerandom'

def compute()
  (25 * 50_000).times do
    var = SecureRandom.base64(10)
    result = Digest::SHA1.hexdigest(var)
  end
  puts 'done'
end

MULTIPLY_TASK_NUMBER = 12

def run_sequential
  puts 'Running sequential'
  MULTIPLY_TASK_NUMBER.times { |x| compute }
end

def run_with_threads
  puts 'Running with threads'
  threads = []
  MULTIPLY_TASK_NUMBER.times do
    threads << Thread.new { compute }
  end
  threads.each(&:join)
end

def run_with_processes
  puts 'Running with processes'
  MULTIPLY_TASK_NUMBER.times do
    fork { compute }
  end
  Process.waitall
end

def run_with_ractors
  puts 'Running with ractor'
  MULTIPLY_TASK_NUMBER.times.map do
    Ractor.new { compute }
  end.each(&:take)
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
#   puts 'Running with ractor'
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

measure_duration { p run_sequential }
puts

measure_duration { p run_with_threads }
puts

measure_duration { p run_with_processes }
puts

measure_duration { p run_with_ractors }
puts