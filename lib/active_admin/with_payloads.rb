# frozen_string_literal: true

module ActiveAdmin
  module WithPayloads
    def append_info_to_payload(payload)
      super
      admin_user = current_admin_user
      payload[:admin_user_id] = admin_user&.try!(:id)
      payload[:admin_user] = admin_user&.try!(:username)
    end
  end
end
