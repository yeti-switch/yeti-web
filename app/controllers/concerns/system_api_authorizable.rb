# frozen_string_literal: true

# Shared-secret bearer-token gate for /api/rest/system/* controllers.
#
# Behaviour:
# - When YetiConfig.api.system.token is blank (or the api.system block is
#   unset), this concern is a no-op (the endpoints stay open, preserving
#   the historical behaviour).
# - When a token is configured, requests must present it as either
#   `Authorization: Bearer <token>` or `?token=<token>`. Comparison is
#   constant-time. Mismatch / absence → 401 with no body.
module SystemApiAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_system_api!
  end

  private

  def authenticate_system_api!
    expected = YetiConfig.api&.system&.token.to_s
    return if expected.empty?

    presented = bearer_token_from_header || params[:token].to_s
    return if presented.present? && tokens_equal?(presented, expected)

    head :unauthorized
  end

  def bearer_token_from_header
    header = request.headers['Authorization'].to_s
    return nil unless header.start_with?('Bearer ')

    header.sub(/\ABearer\s+/, '').strip
  end

  # Constant-time comparison via SHA-256 digests so length differences and
  # byte positions do not leak through timing.
  def tokens_equal?(a, b)
    ActiveSupport::SecurityUtils.fixed_length_secure_compare(
      Digest::SHA256.digest(a),
      Digest::SHA256.digest(b)
    )
  end
end
