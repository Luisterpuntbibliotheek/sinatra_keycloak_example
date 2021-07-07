require_relative 'generic_controller'

class SessionController < GenericController
  before do
    @current_session = current_session

    Keycloak.proc_cookie_token = -> do
      begin
        payload = @current_session.payload
        payload.to_json
      rescue StandardError => e
        puts e.message
        nil
      end
    end
  end

  get '/' do
    begin
      content_type :html
      data = user_info.merge(token: @current_session.token(true).to_json)
      erb :session, { :locals => data }
    rescue StandardError => e
      session.clear
      redirect redirect_login
    end
  end

  get '/login' do
    session.clear
    redirect redirect_login
  end

  get '/logout' do
    redirect '/' unless @current_session.signed_in?
    redirect_logout
  end

end