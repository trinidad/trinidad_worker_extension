# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "trinidad_worker_extension/version"

Gem::Specification.new do |gem|
  gem.name        = "trinidad_worker_extension"
  gem.version     = Trinidad::Extensions::Worker::VERSION
  gem.authors     = ["Karol Bucek"]
  gem.email       = ["self@kares.org"]
  gem.homepage    = "http://github.com/kares/trinidad_worker_extension"
  gem.summary     = %q{Background Worker Extension for Trinidad}
  gem.description = %q{Trinidad background worker extension built upon 
  JRuby-Rack-Worker which provides threaded workers along side your (JRuby-Rack)
  application. Includes (thread-safe) out-of-the-box implementations for popular
  worker libraries such as Resque and Delayed::Job but customized 'daemon' 
  scripts can be used as well.}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  
  gem.extra_rdoc_files = %w[ README.md LICENSE ]
  
  gem.require_paths = ["lib"]
  gem.add_dependency 'trinidad', ">= 1.4.1"
  gem.add_dependency 'jruby-rack-worker', ">= 0.6"
  gem.add_development_dependency 'test-unit'
  gem.add_development_dependency 'mocha'
end