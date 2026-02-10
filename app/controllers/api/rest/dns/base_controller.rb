# frozen_string_literal: true

class Api::Rest::Dns::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include AdminApiAuthorizable

  before_action :set_paper_trail_whodunnit # must be after `include AdminApiAuthorizable`

  def user_for_paper_trail
    current_admin_user&.id || 'Unknown user'
  end

  def handle_exceptions(e)
    capture_error(e) unless e.is_a?(JSONAPI::Exceptions::Error)
    super
  end
end
