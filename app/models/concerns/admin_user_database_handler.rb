# frozen_string_literal: true

module AdminUserDatabaseHandler
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :trackable, :validatable, :ip_allowable
    alias_method :authenticate, :valid_password?

    before_validation do
      self.password = nil if password.blank?
      # disallow to change password with empty confirmation
      self.password_confirmation = nil if password.blank? && password_confirmation.blank?
    end
  end
end
