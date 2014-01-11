# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rangefinder/version'

Gem::Specification.new do |spec|
  spec.name          = "rangefinder"
  spec.version       = Rangefinder::VERSION
  spec.authors       = ["Seamus Abshere"]
  spec.email         = ["seamus@abshere.net"]
  spec.summary       = %q{Helps you find ranges of IDs, like when you're scraping a website and you need to guess IDs.}
  spec.description   = %q{Helps you find ranges of IDs, like when you're scraping a website and you need to guess IDs. You tell it what a valid ID is and it looks for ranges of consecutive valid IDs. It assumes that each probe is expensive.}
  spec.homepage      = "https://github.com/seamusabshere/rangefinder"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'ranges_merger'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
