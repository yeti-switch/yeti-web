# frozen_string_literal: true

# Lists and revokes OAuth tokens granted to MCP clients (Claude Code, Cursor,
# ...). Each row is one access token; revoking marks the record as revoked,
# which invalidates the refresh token stored on the same row, so the client
# loses access permanently (no more refreshes from that authorization).
# Access is role-gated by OauthAccessTokenPolicy (no owner scoping): an admin
# who can see the page sees every token.
ActiveAdmin.register OauthAccessToken do
  menu parent: ['System', 'Admin Access'], label: 'OAuth Access Tokens', priority: 99

  actions :index, :show, :destroy
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  controller do
    # Eager-load application (used in every row) and resource_owner (Owner
    # column) to avoid N+1s. Page-level access is enforced by
    # OauthAccessTokenPolicy; the collection is not scoped by owner.
    def scoped_collection
      super.where(revoked_at: nil).includes(:application, :resource_owner)
    end

    def destroy
      resource.revoke
      flash[:notice] = 'Access token revoked.'
      redirect_to action: :index
    end
  end

  filter :application,
         as: :select,
         collection: -> { OauthApplication.order(:name).pluck(:name, :id) }
  filter :resource_owner,
         as: :select,
         label: 'Owner',
         collection: -> { AdminUser.order(:username).pluck(:username, :id) }
  filter :scopes
  filter :created_at

  index do
    column :id
    column 'Application' do |t|
      t.application&.name || '(deleted)'
    end
    column 'Owner' do |t|
      au = t.resource_owner
      au ? link_to(au.username, admin_user_path(au)) : "id=#{t.resource_owner_id}"
    end
    column :scopes
    column :created_at
    column 'Expires at' do |t|
      t.expires_in ? (t.created_at + t.expires_in.seconds) : 'never'
    end
    actions defaults: false do |t|
      link_to 'Revoke', oauth_access_token_path(t),
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
