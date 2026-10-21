# frozen_string_literal: true

module WellKnown
  module Issuer
    private

    # Emitted verbatim — clients compare `iss` byte for byte, so normalising a
    # trailing slash here would break the logins it looks like it fixes.
    def issuer
      YetiConfig.oauth&.issuer.presence || request.base_url
    end
  end
end
