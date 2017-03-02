module AdminUserDatabaseHandler
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :trackable, :validatable
  end
end