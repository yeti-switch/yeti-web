# frozen_string_literal: true

# activeadmin-oidc prepends its SSO-only login view when OIDC is active.
# yeti-web ships its own login view that handles both DB and OIDC modes,
# so re-prepend app/views to ensure the host view wins.
Rails.application.config.after_initialize do
  require 'active_admin/devise'
  ActiveAdmin::Devise::SessionsController.prepend_view_path(
    Rails.root.join('app/views').to_s
  )
end
