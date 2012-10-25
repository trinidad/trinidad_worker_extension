require 'trinidad'
require 'trinidad_worker_extension/version'
require 'jruby/rack/worker'

module Trinidad
  module Extensions
    class WorkerWebAppExtension < WebAppExtension

      def configure(context)
        if ! options || options.size == 0
          context.logger.info "no worker(s) seems to be configured"
        else
          worker_config = options.first
          if options.size > 1
            context.logger.info "currently only 1 worker configuration per " +
            "web-app is supported, will use first: #{worker_config.inspect}"
          end
          if worker_config.is_a?(Array) # [ key, val ]
            configure_worker context, worker_config[0], worker_config[1]
          else
            configure_worker context, nil, worker_config
          end
        end
      end

      protected
      
      def configure_worker(context, name, config)
        config = config.dup
        if script = config.delete(:script)
          context.add_parameter 'jruby.worker.script', script
        end
        if script_path = config.delete(:script_path)
          context.add_parameter 'jruby.worker.script.path', script_path
        end
        if script.nil? && script_path.nil?
          if name
            context.add_parameter('jruby.worker', name.to_s)
          else
            context.logger.warn "not-starting any workers due missing configuration " + 
            "either set :script or :script_path if you're not using a built-in worker"
            return
          end
        end
        load_worker_jar # load when first worker setup
        config.each do |key, value|
          case key.to_s
          when 'thread_count'
            context.add_parameter('jruby.worker.thread.count', value.to_s)
          when 'thread_priority'
            context.add_parameter('jruby.worker.thread.priority', value.to_s)
          else
            value = value.join(',') if value.respond_to?(:join)
            context.add_parameter(key.to_s, value.to_s)
          end
        end
      end
      
      private
      
      def load_worker_jar
        JRuby::Rack::Worker.load_jar(:require)
      end
      
    end
  end
end