# frozen_string_literal: true

module Importing
  class CodecGroupPolicy < ::RolePolicy
    section 'Importing/CodecGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
