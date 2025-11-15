# frozen_string_literal: true

class JwtToken
  ALGO = 'HS256'
  ES256 = 'ES256'

  class << self
    # @param payload [Hash]
    # @return [String] token
    def encode(payload)
      secret_key = Rails.application.secrets.secret_key_base
      payload[:aud] = Array.wrap(payload[:aud]) unless payload[:aud].nil?
      JWT.encode(payload, secret_key, ALGO)
    end

    # @param token [String]
    # @verify_expiration verify_expiration [Boolean]
    # @return [Hash,nil] payload or nil if token invalid
    def decode(token, verify_expiration:, aud: nil)
      return if token.blank?

      secret_key = Rails.application.secrets.secret_key_base
      decode_options = {
        algorithm: ALGO,
        verify_expiration: verify_expiration,
        aud: aud.nil? ? nil : Array.wrap(aud),
        verify_aud: !aud.nil?
      }
      payload, = JWT.decode(token, secret_key, true, decode_options)
      payload&.symbolize_keys
    rescue JWT::DecodeError
      nil
    end

    private

    def secret_key
      Rails.application.secrets.secret_key_base
    end
  end
end
