# frozen_string_literal: true

module Equipment
  module StirShaken
    class TrustedCertificatePolicy < ::RolePolicy
      section 'Equipment/StirShaken/TrustedCertificate'

      alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
