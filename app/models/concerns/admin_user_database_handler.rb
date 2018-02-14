module AdminUserDatabaseHandler
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :trackable, :validatable
    alias_method :authenticate, :valid_password?
  end
end
