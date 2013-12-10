# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tidepool_analyze/version'

Gem::Specification.new do |gem|
  gem.name          = "tidepool_analyze"
  gem.version       = TidepoolAnalyze::VERSION
  gem.authors       = ["Kerem Karatal"]
  gem.email         = ["kkaratal@tidepool.co"]
  gem.description   = %q{This gem calculates the results for the assessments}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/tidepool/analyze"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", "~> 4.0.2"
  gem.add_development_dependency "rspec", "~> 2.13"
  gem.add_development_dependency "pry-debugger", "~> 0.2"
  gem.add_development_dependency "pry-stack_explorer", "~> 0.4"
end
