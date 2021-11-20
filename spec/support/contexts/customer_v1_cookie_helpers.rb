# frozen_string_literal: true

RSpec.shared_context :customer_v1_cookie_helpers do
  def build_raw_cookie(token, expiration:)
    cookie_name = Authentication::CustomerV1Auth::COOKIE_NAME
    if expiration.nil?
      "#{cookie_name}=#{token}; path=/; HttpOnly; SameSite=Lax"
    else
      expires = expiration.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      "#{cookie_name}=#{token}; path=/; expires=#{expires}; HttpOnly; SameSite=Lax"
    end
  end

  def build_customer_token(api_access_id, expiration:)
    if expiration.nil?
      JwtToken.encode(
        sub: api_access_id,
        aud: [Authentication::CustomerV1Auth::AUDIENCE]
      )
    else
      JwtToken.encode(
        sub: api_access_id,
        aud: [Authentication::CustomerV1Auth::AUDIENCE],
        exp: expiration.to_i
      )
    end
  end

  def build_customer_cookie(api_access_id, expiration:)
    token = build_customer_token(api_access_id, expiration: expiration)
    build_raw_cookie(token, expiration: expiration)
  end
end
