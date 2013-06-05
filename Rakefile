begin
  require 'bundler/gem_helper'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--color', "--format documentation"]
end
task :test => :spec

task :default => :spec