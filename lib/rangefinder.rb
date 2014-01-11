require "rangefinder/version"
require 'rangefinder/memo'

require 'ranges_merger'

class Rangefinder
  PRECISION = 1e3
  MAX = 1e7 # or you could use 4294967295-1
  STARVE = 1e5
  CHUNK = 1e4
  SAMP = 0.01
  ITER = 3

  def probe(options = {}, &blk)
    ranges, _, _ = probe_with_hits_and_misses(options, &blk)
  end

  def probe_with_hits_and_misses(options = {}, &blk)
    memo = Memo.new
    options.fetch(:iter, ITER).times do
      _probe(memo, options, &blk)
    end
    [ ::RangesMerger.merge(memo.ranges), memo.hits, memo.misses ]
    # [ memo.ranges, memo.hits, memo.misses ]
  end

  private

  def _probe(memo, options = {}, &blk)
    a = options.fetch(:a, 0)
    b = options.fetch(:b, MAX)
    samp = options.fetch(:samp, SAMP)
    # raise "samp #{samp} > 0.1" if samp > 0.1
    chunk = options.fetch(:chunk, CHUNK)
    starve = options.fetch(:starve, STARVE)
    ever_good = false
    if chunk <= PRECISION
      found_range = ([(a-chunk).round, 0].max)..([(b+chunk).round, MAX].min)
      memo.ranges << found_range
    else
      first_good = nil
      i = a
      last_good = a
      while i < b and (!ever_good or (last_good - i).abs < starve)
        # puts "while #{i} < #{b} and (#{first_good.inspect}.nil? or #{(i - last_good).abs} < #{starve})"
        if first_good and (last_good - i).abs > chunk
          # _probe memo, {a: first_good, b: last_good, samp: samp*10, chunk: chunk/10}, &blk
          _probe memo, {a: first_good, b: last_good, samp: samp*10, chunk: chunk/10}, &blk
          first_good = nil
          last_good = i
        end
        if memo.ranges.any? { |range| range.include?(i) }
          ever_good = true
          first_good ||= i
          last_good = i
        elsif blk.call(i)
          memo.hit!
          ever_good = true
          first_good ||= i
          last_good = i
        else
          memo.miss!
        end
        i = (i + rand(100) * (1 - samp)).to_i
      end
    end
  end
end
