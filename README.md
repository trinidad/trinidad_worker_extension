# Trinidad Worker Extension

Background Workers for [Trinidad](https://github.com/trinidad/trinidad/) running
as background (daemon) threads along side your Rack/Rails deployed application.

Built upon https://github.com/kares/jruby-rack-worker thus supports popular
worker libraries such as **Resque** and **Delayed::Job**.

## Install

Along with Trinidad in your application's *Gemfile* :

```ruby
  group :server do
    platform :jruby do
      gem 'trinidad', :require => false
      gem 'trinidad_worker_extension', :require => false
    end
  end
```

    $ bundle

Or install it yourself as a plain old gem :

    $ gem install trinidad_worker_extension


## Configure

Like all extensions set it up in the configuration file (e.g. *trinidad.yml*).

**NOTE:** The extension will not be configuring workers threads to start when
running in **rackup** mode (e.g. `rails s`) because it expects JRuby-Rack to be
not loaded in the embedded mode. Running Trinidad using `rackup` is mostly
suitable for development/testing thus this is not seen as a limitation (simply
start `trinidad -e staging` to check whether your workers are doing fine).

### Delayed::Job

```yaml
---
  # ...
  extensions:
    worker:
      delayed_job:
        # all settings here are optional
        thread_count: 1
        thread_priority: NORM
        # DJ specifics (optional as well) :
        QUEUE: mailers,tasks
        READ_AHEAD: 3 # default 5
        SLEEP_DELAY: 2.5 # default 5
        #MIN_PRIORITY: 1
        #MAX_PRIORITY: 5
```

The following start script will be executed in each Thread http://git.io/yLSgLA

### Resque

```ruby
Trinidad.configure do |config|
  config[:extensions] = {
    :worker =>
      :resque => {
        :thread_priority => 4, # bit bellow NORM (5)
        'QUEUES' => ['*'],
        'INTERVAL' => 2.5, # default is 5.0
        'VERBOSE' => true, # verbose logging
        #'VVERBOSE' => true, # very_verbose logging
      }
  }
end
```

The following start script will be executed in each Thread http://git.io/XglTpw

### Custom Worker

```yaml
---
  # ...
  extensions:
    worker:
      custom:
        #script: require 'my_worker'; MyWorker.start
        script.path: "lib/my_worker/start_worker.rb"
        # all settings here are optional
        #thread_count: 1
        #thread_priority: NORM
```

If you'd like to specify custom parameters you can do so within the configuration
file or the deployment descriptor as context init parameters or as java system
properties, use the following code to obtain them in your code :

```ruby
require 'jruby/rack/worker/env'
env = JRuby::Rack::Worker::ENV

worker = MyWorker.new
worker.queues = (env['QUEUES']).split(',')
# ...
```

## Copyright

Copyright (c) 2013 [Karol Bucek](https://github.com/kares).
See LICENSE (http://en.wikipedia.org/wiki/MIT_License) for details.
