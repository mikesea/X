lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "x/version"

Gem::Specification.new do |gem|
  gem.name          = "x-ruby"
  gem.version       = X::VERSION
  gem.authors       = ["Mike Chlipala"]
  gem.email         = %w(mike@chlipala.com)
  gem.description   = %q{Experiment assigner.}
  gem.summary       = %q{Experiment assigner.}
  gem.homepage      = 'https://github.com/mikesea/x'
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(/^test/)
  gem.require_paths = ["lib"]

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
end
