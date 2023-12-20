# frozen_string_literal: true

module AdminApiAuthorizable
  extend ActiveSupport::Concern

  included do
    include Knock::Authenticable
    undef :current_admin_user

    before_action :authenticate_admin_user!
  end

  def context
    { current_admin_user: current_admin_user }
  end

  def capture_user
    return if current_admin_user.nil?

    {
      id: current_admin_user.id,
      username: current_admin_user.username,
      class: 'AdminUser',
      ip_address: '{{auto}}'
    }
  end

  private

  def authenticate_admin_user!
    if !authenticate_for(::AdminUser) || !current_admin_user.ip_allowed?(request.remote_ip)
      unauthorized_entity('admin_user')
    end
  end
end
