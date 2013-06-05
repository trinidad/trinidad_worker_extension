begin
  require 'bundler'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
Bundler.require(:default, :test)

require 'rspec'

lib = File.expand_path('../lib', File.dirname(__FILE__))
$: << lib unless $:.include?(lib)
require 'trinidad_worker_extension'
