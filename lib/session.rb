require 'keycloak'
require 'json'

class Session
  attr_accessor :redirect_uri, :payload, :session_id

  def initialize(payload = nil, session_id = nil, redirect_uri ='http://127.0.0.1:9292/session')
    @payload = payload
    @redirect_uri = redirect_uri
    @session_id = session_id
  end

  def redirect_login_url(redirect_uri = @redirect_uri)
    Keycloak::Client.url_login_redirect(redirect_uri, response_type = 'code')
  end

  def redirect_logout_url(redirect_uri = @redirect_uri)
    Keycloak::Client.logout(redirect_uri)
  end

  def create_by_code(code)
    @payload = JSON.parse(Keycloak::Client.get_token_by_code(code, @redirect_uri))
  end

  def signed_in?
    token.nil? ? false : Keycloak::Client.user_signed_in?(token)
  end

  def active?
    JSON.parse(Keycloak::Client.get_token_introspection(token))['active']
  rescue StandardError
    false
  end

  def token(decode = false)
    return nil if @payload.nil?
    if decode
      JWT.decode(@payload['access_token'], Keycloak::Client.public_key, false, { :algorithm => 'RS256' })
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