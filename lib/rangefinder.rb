require "rangefinder/version"
require 'rangefinder/memo'

require 'ranges_merger'

class Rangefinder
  MAX = 2**32 - 1
  MAX_GAP = 1e5
  INIT_SAMP = 0.01
  MAX_SAMP = 0.1

  def probe(options = {}, &blk)
    ranges, _, _ = probe_with_hits_and_misses(options, &blk)
    ranges
  end

  def probe_with_hits_and_misses(options = {}, &blk)
    memo = Memo.new
    _probe(memo, options, &blk)
    [ ::RangesMerger.merge(memo.ranges), memo.hits, memo.misses ]
  end

  private

  def _probe(memo, options = {}, &blk)
    first = [options.fetch(:first, 0), 0].max.round
    last = [options.fetch(:last, MAX), MAX].min.round
    max_gap = options.fetch(:max_gap, MAX_GAP)
    samp = options.fetch(:samp, INIT_SAMP)
    random = options.fetch(:random, ::Random.new)
    if samp >= MAX_SAMP
      memo.ranges << (first..last)
    else
      min_range = (10 ** (2 - Math.log(samp, 10))).round
      anything = false
      first_good = nil
      i = first
      last_good = first
      begin
        if blk.call(i)
          memo.hit!
          anything = true
          first_good ||= i
          last_good = i
        else
          memo.miss!
        end
        gap = i - last_good
        if first_good and gap > min_range
          _probe memo, {first: first_good-min_range, last: last_good+min_range, samp: samp*3}, &blk
          first_good = nil
          last_good = i
          gap = 0
        end
        samp1 = gap > 10 ? samp * Math.log(gap, 10) : samp
        i += (random.rand(100) * (1 - samp1)).round
      end until i >= last or (gap > max_gap and anything) # sorry for mixed metaphor
    end
  end
end
