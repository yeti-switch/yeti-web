# frozen_string_literal: true

class Api::Rest::Admin::AuthController < Knock::AuthTokenController
  private

  protect_from_forgery with: :null_session

  def entity_name
    'AdminUser'
  end

  def auth_params
    params.require(:auth).permit :username, :password
  end
end
