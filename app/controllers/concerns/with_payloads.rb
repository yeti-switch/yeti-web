# frozen_string_literal: true

module WithPayloads
  def append_info_to_payload(payload)
    super
    payload[:debug_mode] = debug_mode
    payload[:meta] = try(:meta)
  end
end
