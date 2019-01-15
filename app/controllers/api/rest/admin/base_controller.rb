# frozen_string_literal: true

class Api::Rest::Admin::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include Knock::Authenticable
  undef :current_admin_user

  before_action :authenticate_admin_user!

  def context
    { current_admin_user: current_admin_user }
  end

  private

  def authenticate_admin_user!
    unauthorized_entity('admin_user') unless authenticate_for(::AdminUser)
  end
end
