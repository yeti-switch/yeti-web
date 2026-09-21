# frozen_string_literal: true

# Adds the signed in admin to the log record of the request, for every controller that
# authenticates one: the ActiveAdmin pages, the admin JSON API and RemoteStatsController.
#
# Required rather than autoloaded: config/initializers/active_admin.rb mixes it into
# ActiveAdmin::BaseController while the application is still initializing.
module WithAdminUserPayload
  def append_info_to_payload(payload)
    super
    admin_user = current_admin_user
    payload[:admin_user_id] = admin_user&.try!(:id)
    payload[:admin_user] = admin_user&.try!(:username)
  end
end
