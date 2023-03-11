# frozen_string_literal: true

class AdminUserPasswordForm < ProxyForm
  def self.policy_class
    AdminUserPolicy
  end

  with_model_name 'AdminUser'
  model_class 'AdminUser'

  attribute :password, :string
  attribute :password_confirmation, :string

  model_attributes :password,
                   :password_confirmation

  # By default when password and password_confirmation are blank AdminUser will ignore these fields.
  # However in these form fields are required so we will show validation error.
  validates :password, presence: true
  validates :password_confirmation, presence: true
end
