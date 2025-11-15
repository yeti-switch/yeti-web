# frozen_string_literal: true

module CustomerV1Auth
  class TokenBuilder < JwtToken
    class << self
      private

      def secret_key
        Rails.application.secrets.customer_v1_jwt_secret
      end
    end
  end
end
