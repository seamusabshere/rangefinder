class Rangefinder
  class Memo
    attr_reader :ranges
    attr_reader :hits
    attr_reader :misses
    def initialize
      @ranges = []
      @hits = 0
      @misses = 0
      @mutex = Mutex.new
    end
    def hit!
      @mutex.synchronize { @hits += 1 }
    end
    def miss!
      @mutex.synchronize { @misses += 1 }
    end
  end
end
