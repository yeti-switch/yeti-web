# frozen_string_literal: true

class CronJobInfoPolicy < ::RolePolicy
  section 'System/CronJob'

  class Scope < ::RolePolicy::Scope
  end
end
