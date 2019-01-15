# frozen_string_literal: true

module Lnp
  class CachePolicy < ::RolePolicy
    section 'Lnp/Cache'

    class Scope < ::RolePolicy::Scope
    end
  end
end
