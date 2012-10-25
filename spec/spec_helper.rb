begin
  require 'bundler/setup'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end

require 'rspec'
require 'mocha'

lib = File.expand_path('../lib', File.dirname(__FILE__))
$: << lib unless $:.include?(lib)
require 'trinidad_worker_extension'
