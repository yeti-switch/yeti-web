# frozen_string_literal: true

class DialpeerPolicy < ::RolePolicy
  section 'Dialpeer'

  alias_rule :unlock?, to: :perform? # DSL acts_as_lock
  alias_rule :truncate_long_time_stats?, to: :perform? # DSL acts_as_stat
  alias_rule :truncate_short_window_stats?, to: :perform? # DSL acts_as_quality_stat
  alias_rule :enabled?, :disabled?, to: :perform? # DSL acts_as_status

  class Scope < ::RolePolicy::Scope
  end
end
