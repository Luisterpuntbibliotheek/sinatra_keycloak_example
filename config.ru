$LOAD_PATH << '.'
require 'pp'
require 'bundler'

Bundler.require

#require 'rack/cors'
require 'apps/controllers/main_controller'
require 'apps/controllers/session_controller'

use Rack::Cors do
  allow do
    origins '*'
    resource '(', methods: [:get], headers: :any
  end
end

map '/' do
  run MainController
end

map '/session' do
  run SessionController
end