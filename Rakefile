begin
  require 'bundler/gem_helper'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
Bundler::GemHelper.install_tasks

task :test do
  test = ENV['TEST'] || File.join(Dir.getwd, "test/**/*_test.rb")
  test_opts = (ENV['TESTOPTS'] || '').split(' ')
  test_opts = test_opts.push *FileList[test].to_a
  ruby "-Isrc/main/ruby:src/test/ruby", "-S", "testrb", *test_opts
end

task :default => :test