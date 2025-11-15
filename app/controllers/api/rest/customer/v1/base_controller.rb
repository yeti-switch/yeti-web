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
      customer_id: auth_context.customer_id,
      allowed_account_ids: auth_context.account_ids,
      auth_context: auth_context,
      allow_outgoing_numberlists_ids: auth_context.allow_outgoing_numberlists_ids,
      ip_address: '{{auto}}'
    }
  end

  def capture_user
    return if auth_context.nil?

    {
      id: auth_context.api_access_id || 'N/A',
      customer_id: auth_context.customer_id,
      login: auth_context.login || 'N/A',
      class: auth_context.class.name
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
