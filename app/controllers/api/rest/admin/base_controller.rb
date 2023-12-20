# frozen_string_literal: true

class Api::Rest::Admin::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include AdminApiAuthorizable

  def handle_exceptions(e)
    capture_error(e) unless e.is_a?(JSONAPI::Exceptions::Error)
    super
  end
end
