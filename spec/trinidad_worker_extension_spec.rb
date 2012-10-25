require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'yaml'

describe Trinidad::Extensions::WorkerWebAppExtension do
  
  APP_DIR = File.expand_path('app', File.dirname(__FILE__))

  it "configures (delayed) worker" do
    options = YAML.load( File.read(File.join(APP_DIR, 'trinidad.yml')) )
    Trinidad.configure!(options)
    web_app = create_web_app; context = create_web_app_context(web_app)

    Trinidad::Extensions.configure_webapp_extensions(web_app.extensions, tomcat, context)
    
    params = parameters(context)
    expect( params['jruby.worker'] ).to eql 'delayed_job'
    expect( params['jruby.worker.thread.count'] ).to eql '2'
    expect( params['READ_AHEAD'] ).to eql '3'
    expect( params['SLEEP_DELAY'] ).to eql '3.0'
    
    it_includes_worker_lifecycle_listener(context)
  end

  it "configures (resque) worker" do
    Trinidad.configure! { load File.join(APP_DIR, 'trinidad.rb') }
    web_app = create_web_app; context = create_web_app_context(web_app)
    
    Trinidad::Extensions.configure_webapp_extensions(web_app.extensions, tomcat, context)
    
    params = parameters(context)
    expect( params['jruby.worker'] ).to eql 'resque'
    expect( params['jruby.worker.thread.priority'] ).to eql 'MIN'
    expect( params['QUEUES'] ).to eql 'low,normal'
    expect( params['INTERVAL'] ).to eql '1.5'
    expect( params['VERBOSE'] ).to eql 'true'
    
    it_includes_worker_lifecycle_listener(context)
  end
  
  describe 'WorkerLifecycle' do
    
    before do
      Trinidad.configure! { load File.join(APP_DIR, 'trinidad.rb') }
      @web_app = create_web_app; @context = create_web_app_context(@web_app)
      # sets up the worker lifecycle listener :
      Trinidad::Extensions.configure_webapp_extensions(@web_app.extensions, tomcat, @context)
      listeners = @context.find_lifecycle_listeners
      klass = Trinidad::Extensions::WorkerWebAppExtension::WorkerLifecycle
      @lifecycle = listeners.find { |l| l.is_a?(klass) }
      # do what Trinidad server startup would :
      @context.add_lifecycle_listener(@web_app.define_lifecycle)
      
      #@event = mock('event'); @event.stub!(:lifecycle).and_return @context
      @context.start
    end
    
    it "configures worker context listener" do
      class_name = 'org.kares.jruby.rack.WorkerContextListener'
      expect( @context.find_application_listeners ).to include class_name
    end
    
  end
  
  def it_includes_worker_lifecycle_listener(context)
    listeners = context.find_lifecycle_listeners
    klass = Trinidad::Extensions::WorkerWebAppExtension::WorkerLifecycle
    expect( listeners.find { |l| l.is_a?(klass) } ).to_not be nil
  end
  
  protected
  
  def parameters(context)
    context.find_parameters.inject({}) do |hash, name|
      hash[name] = context.find_parameter(name); hash
    end
  end
  
  private
  
  def tomcat
    @tomcat ||= org.apache.catalina.startup.Tomcat.new
  end

  def create_web_app(config = {})
    Trinidad::WebApp.create({ :context_path => '/', :root_dir => APP_DIR }.merge(config))
  end

  def create_web_app_context(context_dir = APP_DIR, web_app_or_context_path = '/')
    context_path, lifecycle = web_app_or_context_path, nil
    if web_app_or_context_path.is_a?(Trinidad::WebApp)
      context_path = web_app_or_context_path.context_path
      lifecycle = web_app_or_context_path.define_lifecycle
    end
    context = tomcat.addWebapp(context_path, context_dir.to_s)
    context_config = org.apache.catalina.startup.ContextConfig.new
    context.addLifecycleListener context_config
    context.addLifecycleListener lifecycle if lifecycle
    context
  end
      
end