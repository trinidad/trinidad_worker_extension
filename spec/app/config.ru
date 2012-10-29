# make sure resque can be loaded :
begin
  require 'resque'
rescue LoadError => e
  require('rubygems') && retry; raise e
end
# and rackup a simple app :
use Rack::CommonLogger
run Proc.new { [200, {'Content-Type' => 'text/plain'}, 'OK'] }