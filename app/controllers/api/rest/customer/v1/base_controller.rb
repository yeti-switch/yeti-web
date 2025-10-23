# frozen_string_literal: true

class Api::Rest::Customer::V1::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include CustomerV1Authorizable
  include ActionController::Cookies

  before_action :authorize!
  after_action :setup_authorization_cookie

  private

  def context
    {
      customer_id: current_customer.customer_id,
      allowed_account_ids: current_customer.account_ids,
      current_customer: current_customer,
      allow_outgoing_numberlists_ids: current_customer.allow_outgoing_numberlists_ids,
      ip_address: '{{auto}}'
    }
  end

  def capture_user
    return if current_customer.nil?

    {
      id: current_customer.id,
      customer_id: current_customer.customer_id,
      login: current_customer.login,
      class: current_customer.class.name
    }
  end

  def handle_authorization_error
    handle_exceptions(JSONAPI::Exceptions::AuthorizationFailed.new)
  end

  def handle_exceptions(e)
    capture_error(e) unless e.is_a?(JSONAPI::Exceptions::Error)
    super
  end
end
