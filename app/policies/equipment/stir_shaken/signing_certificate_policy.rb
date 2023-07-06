# frozen_string_literal: true

module Equipment
  module StirShaken
    class SigningCertificatePolicy < ::RolePolicy
      section 'Equipment/StirShaken/SigningCertificate'

      alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
