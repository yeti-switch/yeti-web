# frozen_string_literal: true

RSpec.shared_context :customer_v1_cookie_helpers do
  def build_raw_cookie(token, expiration:)
    cookie_name = CustomerV1Auth::Authenticator::COOKIE_NAME
    if expiration.nil?
      "#{cookie_name}=#{token}; path=/; httponly; samesite=lax"
    else
      expires = expiration.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      "#{cookie_name}=#{token}; path=/; expires=#{expires}; httponly; samesite=lax"
    end
  end

  def build_customer_token(api_access_id, expiration:)
    attrs = CustomerV1Auth::AuthContext.members.index_with { nil }
    auth_context = CustomerV1Auth::AuthContext.new(**attrs, api_access_id:)
    CustomerV1Auth::Authenticator.build_token(auth_context, expires_at: expiration)
  end

  def build_customer_token_from_config(config, expiration:)
    auth_context = CustomerV1Auth::AuthContext.from_config(config)
    CustomerV1Auth::Authenticator.build_token(auth_context, expires_at: expiration)
  end

  def build_customer_cookie(api_access_id, expiration:)
    token = build_customer_token(api_access_id, expiration: expiration)
    build_raw_cookie(token, expiration: expiration)
  end

  def build_customer_cookie_from_config(auth_context, expiration:)
    token = build_customer_token_from_config(auth_context, expiration: expiration)
    build_raw_cookie(token, expiration: expiration)
  end
end
