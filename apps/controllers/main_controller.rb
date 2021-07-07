require_relative 'generic_controller'

class MainController < GenericController

  get '/' do
    erb :main
  end

  get '/remote_user/:id' do
    content_type :json
    user_by_id(params[:id]).to_json
  end

end