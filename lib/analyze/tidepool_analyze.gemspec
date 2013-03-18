# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tidepool_analyze/version'

Gem::Specification.new do |gem|
  gem.name          = "tidepool_analyze"
  gem.version       = TidepoolAnalyze::VERSION
  gem.authors       = ["Kerem Karatal"]
  gem.email         = ["kkaratal@tidepool.co"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport"
  gem.add_development_dependency "rspec", "~> 2.13"
  
end
