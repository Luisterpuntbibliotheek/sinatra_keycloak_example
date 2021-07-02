require_relative 'generic_controller'

class SessionController < GenericController
  before do
    @current_session = current_session

    Keycloak.proc_cookie_token = -> do
      begin
        puts "getting token"
        token = @current_session.payload
        puts token
        token
      rescue StandardError => e
        puts e.message
        nil
      end
    end
  end

  get '/' do
    begin
      content_type :html
      erb :session, { :locals => user_info }
    rescue StandardError => e
      redirect_login
    end
  end

  get '/login' do
    redirect_login
  end

  get '/logout' do
    redirect_logout
  end

end