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
        params = {}
        if script = config.delete(:script)
          params['jruby.worker.script'] = script
        end
        if script_path = config.delete(:script_path)
          params['jruby.worker.script.path'] = script_path
        end
        if script.nil? && script_path.nil?
          if name
            params['jruby.worker'] = name.to_s
          else
            context.logger.warn "not-starting any workers due missing configuration " + 
            "either set :script or :script_path if you're not using a built-in worker"
            return
          end
        end
        config.each do |key, value|
          case key.to_s
          when 'thread_count'
            params['jruby.worker.thread.count'] = value.to_s
          when 'thread_priority'
            params['jruby.worker.thread.priority'] = value.to_s
          else
            value = value.join(',') if value.respond_to?(:join)
            params[key.to_s] = value.to_s
          end
        end
        context.add_lifecycle_listener listener = WorkerLifecycle.new(params)
        listener
      end
      
      CONTEXT_LISTENER = 'org.kares.jruby.rack.WorkerContextListener'
      
      class WorkerLifecycle < Trinidad::Lifecycle::Base
        
        attr_reader :context_parameters
        
        def initialize(params)
          @context_parameters = params || {}
          if @context_parameters.empty?
            raise ArgumentError, "no context parameters"
          end
        end
        
        def configure_start(event)
          context = event.lifecycle
          add_context_parameters(context)
          add_class_loader_jar_url(context)
          # NOTE: it's important for this listener to be added after
          # the Rack setup as it expectd to find the RackFactory ...
          # that's why we hook into #configure_start which happens
          # right after #before_start but before the actual #start !
          add_application_listener(context)
        end
        
        protected
        
        def add_context_parameters(context)
          app_params = context.find_application_parameters
          context_parameters.each do |name, value|
            if app_param = app_params.find { |param| param.name == name }
              app_param.value = value
            else
              # a "better" context.add_parameter(name, value) :
              app_param = Trinidad::Tomcat::ApplicationParameter.new
              app_param.name = name; app_param.value = value
              app_param.override = false # confusing to override in web.xml
              context.add_application_parameter app_param
            end
          end
        end
        
        def add_class_loader_jar_url(context)
          jar_file = java.io.File.new JRuby::Rack::Worker::JAR_PATH
          class_loader = context.loader.class_loader
          unless class_loader.getURLs.include?(jar_file.to_url)
            class_loader.addURL jar_file.to_url
          end
        end
        
        def add_application_listener(context)
          listener = CONTEXT_LISTENER
          unless context.find_application_listeners.include?(listener)
            context.add_application_listener listener
          end
        end
        
      end
      
    end
  end
end