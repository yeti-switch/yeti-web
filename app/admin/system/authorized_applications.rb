# frozen_string_literal: true

# Lets each admin see and revoke OAuth tokens they've granted to MCP clients
# (Claude Code, Cursor, ...). Each row is one active access token; revoking
# kills the access token immediately so the client can no longer call /api/mcp.
# The refresh token chain still exists separately — revoking access tokens
# only buys ~1h of immunity until the refresh succeeds; for a permanent kill,
# revoke once more after refresh, or use the bulk action to revoke all tokens
# for the application.
ActiveAdmin.register OauthAccessToken, as: 'AuthorizedApplication' do
  menu parent: 'System', label: 'Authorized Applications', priority: 99

  actions :index, :show, :destroy
  config.batch_actions = false
  config.filters = false
  config.sort_order = 'created_at_desc'

  controller do
    # Per-user scoping is handled by OauthAccessTokenPolicy::Scope.
    # We only need to exclude already-revoked tokens here.
    def scoped_collection
      super.where(revoked_at: nil)
    end

    def destroy
      resource.revoke
      flash[:notice] = 'Access token revoked.'
      redirect_to action: :index
    end
  end

  index do
    column :id
    column 'Application' do |t|
      t.application&.name || '(deleted)'
    end
    if current_admin_user.roles.compact.map(&:to_sym).include?(RolePolicy.root_role)
      column 'Owner' do |t|
        au = AdminUser.find_by(id: t.resource_owner_id)
        au ? link_to(au.username, admin_user_path(au)) : "id=#{t.resource_owner_id}"
      end
    end
    column :scopes
    column :created_at
    column 'Expires at' do |t|
      t.expires_in ? (t.created_at + t.expires_in.seconds) : 'never'
    end
    actions defaults: false do |t|
      link_to 'Revoke', authorized_application_path(t),
              method: :delete,
              data: { confirm: 'Revoke this token? The client will lose access immediately.' }
    end
  end

  show do
    attributes_table do
      row :id
      row 'Application' do |t|
        t.application&.name || '(deleted)'
      end
      row 'Client UID' do |t|
        t.application&.uid
      end
      row :scopes
      row :created_at
      row 'Expires at' do |t|
        t.expires_in ? (t.created_at + t.expires_in.seconds) : 'never'
      end
      row :revoked_at
    end
  end
end
