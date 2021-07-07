require 'keycloak'

module Sinatra
  module SessionHelper
    def redirect_login(redirect_uri = "http://127.0.0.1:9292/session")
      current_session.redirect_login_url(redirect_uri)
    end

    def redirect_logout(redirect_uri = "http://127.0.0.1:9292/")
      current_session.redirect_logout_url(redirect_uri)
    end

    def current_session
      session_id = session[:session_id]
      internal_session = settings.s_store[session_id]

      unless internal_session.payload
        puts "no session"
        if params.key?(:code)
          settings.s_store[session_id] = internal_session.create_by_code(params[:code])
          unless settings.s_store[session_id].active?
            raise Session::Bad
          end
        end
      end

      settings.s_store[session_id]
    rescue Session::Bad
      session.clear
      redirect internal_session.redirect_login_url
    end

    def signed_in?
      current_session.signed_in?
    end

    def user_info
      return nil unless current_session.active?
      current_session.user_info
    end

    def user_by_id(id)
      response = HTTP.get("https://data.luisterpunt.vlaanderen/gebruikers/#{id}", headers: {'Authorization': "Bearer #{current_session.token}"})
      if response.status == 200
        JSON.parse(response.body.to_s)
      else
        JSON.parse(response.body.to_s)
      end
    end

  end
  helpers SessionHelper
end