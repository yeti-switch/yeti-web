# frozen_string_literal: true

module Concerns::WithPayloads
  def append_info_to_raw_payload(payload)
    payload[:debug_mode] = debug_mode
    payload[:request] = request
    payload[:remote_ip] = request.env['HTTP_X_REAL_IP'] || request.remote_ip
  end

  def append_info_to_payload(payload)
    super
    payload[:response] = response
  end
end
