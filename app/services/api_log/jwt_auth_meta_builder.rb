# frozen_string_literal: true

module ApiLog
  class JwtAuthMetaBuilder
    CUSTOMER_CFG_CLAIMS = %i[
      customer_id
      account_ids
      allow_listen_recording
      allow_outgoing_numberlists_ids
      allowed_ips
      customer_portal_access_profile_id
      provision_gateway_id
    ].freeze

    # @param payload [Hash,nil]
    def initialize(payload:)
      @payload = payload
    end

    # @return [Hash,nil]
    def call
      return if payload.blank?

      auth_meta = {}
      auth_meta['aud'] = payload[:aud] if payload.key?(:aud)
      auth_meta['sub'] = payload[:sub] if payload.key?(:sub)
      merge_customer_cfg!(auth_meta)
      auth_meta.presence
    end

    private

    attr_reader :payload

    def merge_customer_cfg!(auth_meta)
      cfg = payload[:cfg]
      return unless cfg.is_a?(Hash)

      cfg = cfg.symbolize_keys.slice(*CUSTOMER_CFG_CLAIMS)
      return if cfg.empty?

      auth_meta['cfg'] = cfg.deep_stringify_keys
    end
  end
end
