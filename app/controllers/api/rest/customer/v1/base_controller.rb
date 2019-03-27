# frozen_string_literal: true

class Api::Rest::Customer::V1::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include Knock::Authenticable
  rescue_from JSONAPI::Exceptions::AuthorizationFailed, with: :handle_exceptions

  undef :current_admin_user

  before_action :authenticate_api_access!

  def context
    {
      customer_id: current_customer.customer_id,
      allowed_account_ids: current_customer.account_ids,
      current_customer: current_customer
    }
  end

  def current_customer
    current_system_apiaccess
  end

  private

  def authenticate_api_access!
    authenticate_for(System::ApiAccess)
    raise JSONAPI::Exceptions::AuthorizationFailed if current_customer.nil?
  end
end
