# frozen_string_literal: true

module Notification
  class AlertPolicy < ::RolePolicy
    section 'Notification/Alert'

    class Scope < ::RolePolicy::Scope
    end
  end
end
