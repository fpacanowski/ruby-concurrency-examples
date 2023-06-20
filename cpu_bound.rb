require 'digest'

def compute(input)
  # this is relying on C extension
  # 50_000.times do
  #   result = Digest::SHA512.hexdigest(result) # digest is using C extensions
  # end

  result = input.to_s
  1500.times do |i|
    Math.sqrt(23467**2436) * i / 0.2
  end

  # https://github.com/TheRusskiy/ruby3-http-server
  # this is SLOWER with ractors
  # 500.times do |i|
  #   1000.downto(1) do |j|
  #     Math.sqrt(j) * i / 0.2
  #   end
  # end

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

def run_with_ractors
  ractors = (1..100).each_slice(25).map do |slice|
    Ractor.new do
      Ractor.recv.map { |x| compute(x) }
    end.tap { |r| r << slice }
  end

  ractors.size.times do # wait for ractor termination
    r, obj = Ractor.select(*ractors)
    ractors.delete(r)
  end
end

require './helpers'

Benchmark.benchmark('', nil, "\n" + FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Threads \n")  { run_with_threads }
  x.report("Processes \n")  { run_with_processes }
  x.report("Ractors \n")  { run_with_ractors }
end