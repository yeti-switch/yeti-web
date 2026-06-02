# frozen_string_literal: true

# Lists OAuth tokens granted to MCP clients (Claude Code, Cursor, ...), both
# active and revoked. Each row is one access token; revoking marks the record
# as revoked, which invalidates the refresh token stored on the same row, so
# the client loses access permanently (no more refreshes from that
# authorization) — the row stays, with its Revoked at populated.
# Access is role-gated by OauthAccessTokenPolicy (no owner scoping): an admin
# who can see the page sees every token.
ActiveAdmin.register OauthAccessToken do
  menu parent: ['System', 'Admin Access'], label: 'OAuth Access Tokens', priority: 99

  actions :index, :show, :destroy
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  includes :application, :resource_owner

  controller do
    def destroy
      resource.revoke
      flash[:notice] = 'Access token revoked.'
      redirect_to action: :index
    end
  end

  filter :application, as: :select
  filter :resource_owner, as: :select
  filter :scopes
  filter :created_at

  index do
    column :id
    column :application
    column :resource_owner
    column :scopes
    column :created_at
    column 'Expires at' do |t|
      t.expires_in ? (t.created_at + t.expires_in.seconds) : 'never'
    end
    column :revoked_at
    actions defaults: false do |t|
      # Already-revoked tokens have nothing left to revoke.
      unless t.revoked?
        link_to 'Revoke', oauth_access_token_path(t),
                method: :delete,
                data: { confirm: 'Revoke this token? The client will lose access immediately.' }
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :application
      row :scopes
      row :created_at
      row 'Expires at' do |t|
        t.expires_in ? (t.created_at + t.expires_in.seconds) : 'never'
      end
      row :revoked_at
    end
  end
end
