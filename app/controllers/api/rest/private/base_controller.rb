class Api::Rest::Private::BaseController < Api::RestController
  include Knock::Authenticable
  undef :current_admin_user

  before_action :authenticate_admin_user!

  private

  def authenticate_admin_user!
    unauthorized_entity('admin_user') unless authenticate_for(::AdminUser)
  end
end
