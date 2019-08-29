# frozen_string_literal: true

module Yeti
  module IncomingAuthReloader
    extend ActiveSupport::Concern
    included do
      before_create :reload_incoming_auth!, if: :reload_incoming_auth_on_create?
      before_update :reload_incoming_auth!, if: :reload_incoming_auth_on_update?
      before_destroy :reload_incoming_auth!, if: :reload_incoming_auth_on_destroy?

      private :reload_incoming_auth!,
              :reload_incoming_auth_on_create?,
              :reload_incoming_auth_on_update?,
              :reload_incoming_auth_on_destroy?
    end

    def reload_incoming_auth!
      Event.reload_incoming_auth
    end

    def reload_incoming_auth_on_create?
      true
    end

    def reload_incoming_auth_on_update?
      true
    end

    def reload_incoming_auth_on_destroy?
      true
    end
  end
end
