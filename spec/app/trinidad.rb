Trinidad.configure do |config|
  worker_config = {}
  worker_config[:resque] = {
    :thread_priority => 'MIN',
    'QUEUES' => ['low', 'normal'],
    'INTERVAL' => 1.5,
    'VERBOSE' => true
  }
  worker_config[:another] = { # ignored
    :script => ' puts "another-worker"; sleep(0.5); ',
    :thread_priority => 5, :CUSTOM_PARAM => 4.2
  }
  worker_config[:resque] ={
    :thread_priority => 'MIN',
    'QUEUES' => ['low', 'normal'],
    'INTERVAL' => 1.5,
    'VERBOSE' => true
  }
  config[:extensions] = {
    :worker => worker_config
  }
end