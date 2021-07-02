require 'keycloak'

module Sinatra
  module SessionHelper
    def redirect_login
      current_session.redirect_login_url
    end

    def redirect_logout
      current_session.redirect_logout_url(request.env['HTTP_REFERER'])
    end

    def current_session
      session_id = session[:session_id]
      session = settings.s_store[session_id]

      unless session.active?
        puts "no session"
        if params.key?(:code)
          settings.s_store[session_id] = session.create_by_code(params[:code])
        else
          pp request
          redirect session.redirect_login_url
        end
      else
        puts "has session"
      end

      settings.s_store[session_id]
    end

    def signed_in?
      current_session.signed_in?
    end

    def user_info
      return nil if current_session.nil?
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