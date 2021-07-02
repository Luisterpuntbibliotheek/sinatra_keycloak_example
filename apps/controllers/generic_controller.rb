require 'http'
require 'sinatra/base'
require 'keycloak'
require 'sinatra/cookies'
require 'json'

require 'lib/session_store'
require 'apps/helpers/session_helper'

class GenericController < Sinatra::Base
  helpers Sinatra::Cookies
  helpers Sinatra::SessionHelper

  enable :sessions

  configure do
    set :logging, true
    set :static, true
    set :root, File.absolute_path("#{File.dirname(__FILE__ )}/../../")
    set :views, "#{root}/apps/views"
    set :s_store, SessionStore.new("#{root}/sessions", self)
  end

  not_found do
    "Not found"
  end

  error do
    "Something is seriously wrong"
  end
end