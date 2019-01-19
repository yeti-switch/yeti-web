# frozen_string_literal: true

module AdminUserDatabaseHandler
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :trackable, :validatable
    alias_method :authenticate, :valid_password?

    before_validation do
      self.password = nil if password.blank?
      self.password_confirmation = nil if password_confirmation.blank?
    end
  end
end
