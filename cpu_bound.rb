require 'digest'
require 'parallel'
goru_enabled = ENV['GORU'].to_s != ''
require 'polyphony' unless goru_enabled
require 'goru' if goru_enabled

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

# def run_with_goru_reactors
#   reactors = (1..100).each_slice(25).map do |slice|
#     scheduler = Goru::Scheduler.new # (count: 4)
#     scheduler.go { |routine| slice.map { |x| compute(x) }; routine.finished('OK') }
#     scheduler
#   end
#   reactors.each { |scheduler| scheduler.wait }

#   # pp routines.map(&:result)
# end

def run_with_goru_routines
  scheduler = Goru::Scheduler.new(count: 4)
  routines = (1..100).each_slice(25).map do |slice|
    scheduler.go { |routine| slice.map { |x| compute(x) }; routine.finished('OK') }
  end
  scheduler.wait
  # pp routines.map(&:result)
end

def run_with_polyphony
  fibers = (1..100).each_slice(25).map do |slice|
    spin { slice.map { |x| compute(x) } }
  end

  Fiber.await(*fibers)
end

def run_parallel_threads
  arguments = (1..100).each_slice(25).to_a
  Parallel.map(arguments, in_threads: 4) do |slice|
    slice.map { |x| compute(x) }
  end
end

def run_parallel_processes
  arguments = (1..100).each_slice(25).to_a
  Parallel.map(arguments, in_processes: 4) do |slice|
    slice.map { |x| compute(x) }
  end
end

class RactorClass
  def self.expensive_calculus(slice)
    slice.map do
      1500.times do |i|
        Math.sqrt(23467**2436) * i / 0.2
      end
      print '.'
    end
  end
end

def run_parallel_ractors
  arguments = (1..100).each_slice(25).to_a
  Parallel.map(arguments, in_ractors: 4, ractor: [RactorClass, :expensive_calculus])
end

require './helpers'

Benchmark.benchmark('', nil, "\n" + FORMAT_WITH_SUBPROCESSES) do |x|
  x.report("Sequential \n") { run_sequential }
  x.report("Processes \n")  { run_with_processes }
  x.report("Threads \n")  { run_with_threads }
  # x.report("Goru Reactors \n")  { run_with_goru_reactors }
  x.report("Goru Routines \n")  { run_with_goru_routines } if goru_enabled
  x.report("Polyphony \n")  { run_with_polyphony }         unless goru_enabled
  x.report("Parallel threads \n") { run_parallel_threads }
  x.report("Parallel processes \n") { run_parallel_processes }
  x.report("Parallel ractors \n") { run_parallel_ractors }
  x.report("Ractors \n")  { run_with_ractors }
end