# Rangefinder

Helps you find ranges of IDs, like when you're scraping a website and you need to guess IDs.

You tell it what a valid ID is and it looks for ranges of consecutive valid IDs. It assumes that each probe is expensive.

## Installation

Add this line to your application's Gemfile:

    gem 'rangefinder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rangefinder

## Usage

Let's say you're rainbow tabling a website but you have to guess the IDs. What you **don't** know is that all valid ids are in the ranges `100..11_000` and `100_000..110_000`. You pass a "probe" block that returns true if an ID is valid:

    ranges = Rangefinder.new.probe do |possible_id|
      # your probe code here. for example:
      response = http.get "http://example.com/items", id: possible_id
      response.status == 200
    end

You get back ranges where we think there are valid IDs. In this case, pretty good! (See Goals above)

    >> ranges
    => [ 0..12_200, 99_455..111_600 ]

Now you can scrape them one by one:

    ranges.each do |range|
      range.each do |id|
        # scrape this ID
      end
    end

### Please do cache

It's nice when your probe block makes a call that is cached somehow. That way when you go back and use the ranges, you're not hitting all those URLs over again.

##$ Goals

By default

1. Detect at least 90% of valid IDs in 1000-long ranges with up to 90% intra-range sparsity
1. Tolerate gaps of 100,000
1. Probe no more than 5% of the range

Maybe

1. Don't overestimate valid ranges more than X

### Wishlist

1. Accept a known ID as the basis for smarter probing
1. Internally, calculate density and use that to choose `min_range` and `samp`

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rangefinder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
