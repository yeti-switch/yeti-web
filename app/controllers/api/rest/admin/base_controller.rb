# frozen_string_literal: true

class Api::Rest::Admin::BaseController < Api::RestController
  include JSONAPI::ActsAsResourceController
  include AdminApiAuthorizable

  before_action :set_paper_trail_whodunnit # must be after `include AdminApiAuthorizable`

  def user_for_paper_trail
    current_admin_user&.id || 'Unknown user'
  end

  def handle_exceptions(e)
    capture_error(e) unless e.is_a?(JSONAPI::Exceptions::Error)
    # rescue_from handlers (e.g. auth failures in before_action) call this before
    # the JSONAPI flow has set up and rendered the response document; in 0.9
    # handle_exceptions rendered directly, but 26.x only appends to the document
    # and renders separately. Do that here when invoked outside the flow.
    render_standalone = @response_document.nil?
    setup_response_document if render_standalone
    super
    render_response_document if render_standalone
  end
end
