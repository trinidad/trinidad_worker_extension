Trinidad.configure do |config|
  config[:jruby_min_runtimes] = 1
  config[:jruby_max_runtimes] = 1
  
  worker_config = {}
  worker_config[:resque] = {
    :thread_priority => 'MIN',
    'QUEUES' => ['low', 'normal'],
    'INTERVAL' => 1.5,
    'VERBOSE' => true
  }
  config[:extensions] = {
    :worker => worker_config
  }
end