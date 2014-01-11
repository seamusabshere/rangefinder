require 'spec_helper'

# https://github.com/rails/rails/blob/444ce93397dba3505ecef4973edba40de4fc08c6/activesupport/lib/active_support/core_ext/range/include_range.rb#L12
#  (1..5).include?(1..5) # => true
#  (1..5).include?(2..3) # => true
#  (1..5).include?(2..6) # => false
def range_include?(zelf, other)
  # 1...10 includes 1..9 but it does not include 1..10.
  operator = zelf.exclude_end? && !other.exclude_end? ? :< : :<=
  zelf.include?(other.first) && other.last.send(operator, zelf.last)
end

describe Rangefinder do
  expected_ranges = []
  pos = 0
  100.times do
    len = 1000
    pos += rand(100_000).to_i
    expected_ranges << ((pos)..(len+pos))
  end
  expected_id_count = expected_ranges.map(&:count).inject(:+)

  cache = {}

  (0..0.9).step(0.1).each do |sparsity|
    describe "sparsity=#{'%g' % sparsity}" do
      found_ranges, hits, misses = Rangefinder.new.probe_with_hits_and_misses do |i|
        r = (cache[i] ||= rand)
        (r > sparsity) && expected_ranges.any? { |r| r.include?(i) }
      end

      # $stderr.puts
      # $stderr.puts
      # $stderr.puts "found_ranges=#{found_ranges}"
      # $stderr.puts
      # $stderr.puts "expected_ranges=#{expected_ranges}"

      # it "finds #{expected_ranges.length} ranges" do
      #   expected_ranges.each do |expected|
      #     expect(found_ranges.any? { |found| range_include?(found, expected) }).to be_true, "#{expected} not in #{found_ranges} found"
      #   end
      # end

      it "finds 95% of ids" do
        real_found_ids = []
        expected_ranges.each do |expected|
          found_ranges.each do |found|
            # if found.include?(expected)
            if range_include?(found, expected)
              real_found_ids << expected.to_a
            end
          end
        end
        real_found_ids = real_found_ids.flatten.uniq
        expect((real_found_ids.count.to_f / expected_id_count).round(2)).to be >= 0.95
      end

      it "probes only 5% of the space" do
        highest_id = expected_ranges.map(&:last).max
        expect(((hits+misses).to_f / highest_id).round(2)).to be <= 0.05
      end

      it "exaggerates no more than 5%" do
        found_ids = found_ranges.map(&:to_a).flatten.uniq
        expect((found_ids.count.to_f / expected_id_count).round(2)).to be <= 1.05
      end
    end
  end

end
