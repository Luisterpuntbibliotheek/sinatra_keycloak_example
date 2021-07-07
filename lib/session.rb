require 'keycloak'
require 'json'

class Session
  attr_accessor :redirect_login, :redirect_logout, :payload, :session_id

  def initialize(payload = nil, session_id = nil, redirect_login ='http://127.0.0.1:9292/session', redirect_logout ='http://127.0.0.1:9292/')
    @payload = payload
    @redirect_login = redirect_login
    @redirect_logout = redirect_logout
    @session_id = session_id
  end

  def redirect_login_url(redirect_uri = @redirect_login)
    Keycloak::Client.url_login_redirect(redirect_uri || @redirect_login, response_type = 'code')
  end

  def redirect_logout_url(redirect_uri = @redirect_logout)
    Keycloak::Client.logout(redirect_uri || @redirect_logout)
  end

  def create_by_code(code)
    @payload = JSON.parse(Keycloak::Client.get_token_by_code(code, @redirect_login))
  rescue RestClient::BadRequest => e
    nil
  end

  def signed_in?
    token.nil? ? false : Keycloak::Client.user_signed_in?(token)
  end

  def active?
    return false if token.nil?
    JSON.parse(Keycloak::Client.get_token_introspection(token))['active']
  rescue StandardError
    false
  end

  def refresh()
    Keycloak::Client.get_token_by_refresh_token
  end

  def token(decode = false)
    return nil if @payload.nil?
    if decode
      Keycloak::Client.decoded_access_token(@payload['access_token'])
    else
      @payload['access_token']
    end
  end

  def user_info
    return nil if token.nil?
    user = JSON.parse(Keycloak::Client.get_userinfo_issuer(token))
    raise user['error'] if user.keys.include?('error')

    user.transform_keys(&:to_sym)
  end

  def to_json(*_args)
    @payload.to_json(_args)
  end

end

class Session::Bad < StandardError
end

class Session::Unknown < StandardError
end