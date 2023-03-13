require 'benchmark'

FORMAT_WITH_SUBPROCESSES =
  "u:%10.6u s:%10.6y t:%10.6t elapsed: %10.6r |children| u: %10.6U s:%10.6Y \n\n"

def measure_duration
  time = Benchmark.realtime { yield }
  puts "Real time elapsed: (#{'%10.6f' % time})"
end
