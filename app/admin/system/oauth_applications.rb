# frozen_string_literal: true

# Registered OAuth/OIDC clients — the things that sign users in through yeti or
# call its API: yeti-statistics, Grafana, an internal tool. This page is the only
# way to register one.
#
# MCP clients (Claude Code, Cursor, ...) do not need this page: they self-register
# through POST /oauth/register (RFC 7591) as public PKCE clients. They still show
# up in the list once they have.
#
# Access is role-gated by OauthApplicationPolicy, and root-only until some role
# is granted the "System/OauthApplication" section in config/policy_roles.yml.
# That default matters more here than on most pages: the show page displays the
# client secret in cleartext — which is how Doorkeeper stores it, and which an
# operator configuring a client has to be able to read back.
ActiveAdmin.register OauthApplication do
  menu parent: ['System', 'Admin Access'], label: 'OAuth Applications', priority: 98

  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  # uid and secret may only be chosen at registration time — letting them change
  # afterwards would silently break a client that is already using them, and the
  # form doesn't offer them on edit. Permitting them only on create means a
  # hand-crafted POST can't do it either.
  permit_params do
    permitted = %i[name redirect_uri confidential]
    permitted += %i[uid secret] if params[:action] == 'create'
    permitted + [{ scopes: [] }]
  end

  filter :name
  filter :uid, label: 'Client ID'
  filter :scopes
  filter :confidential
  filter :created_at

  index do
    column :id
    column :name
    column 'Client ID', :uid
    column :scopes
    column :confidential
    column :redirect_uri
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row('Client ID', &:uid)
      # Cleartext, deliberately: this is the only place an operator can recover
      # it, and Doorkeeper is storing it in cleartext regardless.
      row('Client secret', &:plaintext_secret)
      row :scopes
      row('Confidential', &:confidential?)
      row :redirect_uri
      row :created_at
      row :updated_at
    end

    panel 'Active tokens' do
      # Deleting the client deletes these with it (dependent: :delete_all).
      para "#{oauth_application.access_tokens.where(revoked_at: nil).count} not revoked"
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :name, hint: 'Shown in the consent screen the admin is asked to approve.'
      f.input :redirect_uri,
              as: :text,
              input_html: { rows: 3 },
              hint: 'Where the client is sent back after sign-in. Must match what the client ' \
                    'sends byte for byte, base path included, and must be HTTPS unless the host ' \
                    'is a loopback address. One per line for several.'
      # Before :scopes, not after — a lone boolean checkbox rendered directly
      # beneath the scopes checkbox list reads as one more scope.
      f.input :confidential,
              hint: 'On for a client that can keep a secret (a server, like yeti-statistics). ' \
                    'Off for a public client that authenticates with PKCE alone.'
      f.input :scopes,
              as: :check_boxes,
              collection: Doorkeeper.config.scopes.all,
              hint: 'openid is what makes this an OIDC login and produces an id_token. ' \
                    'Leave empty to grant the default scopes.'

      if f.object.new_record?
        # required: false — the model does validate presence, but Doorkeeper
        # fills both in before validation when they are blank, so marking them
        # required would claim the operator has to invent them.
        f.input :uid, label: 'Client ID',
                      required: false,
                      hint: 'Leave blank to generate. Set it to a fixed value when the client ' \
                            'config is deployed from a template.'
        f.input :secret, label: 'Client secret',
                         required: false,
                         hint: 'Leave blank to generate.'
      end
    end

    f.actions
  end

  # Replaces a leaked or rotated secret without deleting the client, so existing
  # tokens keep working — only the client's ability to get new ones is affected
  # until its config is updated.
  member_action :rotate_secret, method: :put do
    resource.renew_secret
    resource.save!
    redirect_to resource_path(resource), notice: 'Client secret rotated. The client must be reconfigured with the new one.'
  end

  action_item :rotate_secret, only: :show do
    if authorized?(:rotate_secret)
      # Url options and html options must stay separate hashes here, or `method`
      # and `data` end up as query parameters and the link silently becomes a GET
      # with no confirmation.
      link_to 'Rotate secret',
              { action: :rotate_secret, id: resource.id },
              method: :put,
              data: { confirm: 'Replace this client secret? The client stops being able to ' \
                               'obtain new tokens until it is reconfigured.' }
    end
  end
end
