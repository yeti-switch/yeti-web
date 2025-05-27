# frozen_string_literal: true

module ActiveAdmin
  module WithPayloads
    def append_info_to_payload(payload)
      super
      payload[:admin_user_id] = current_admin_user&.try!(:id)
    end
  end
end
