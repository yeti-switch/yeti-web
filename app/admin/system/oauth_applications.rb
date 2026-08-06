# frozen_string_literal: true

ActiveAdmin.register OauthApplication do
  menu parent: ['System', 'Admin Access'], label: 'OAuth Applications', priority: 98

  config.batch_actions = false
  config.sort_order = 'created_at_desc'

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
      row('Client secret', &:plaintext_secret)
      row :scopes
      row('Confidential', &:confidential?)
      row :redirect_uri
      row :created_at
      row :updated_at
    end

    panel 'Active tokens' do
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
      f.input :confidential,
              hint: 'On for a client that can keep a secret (a server-side app). ' \
                    'Off for a public client that authenticates with PKCE alone.'
      f.input :scopes,
              as: :check_boxes,
              collection: Doorkeeper.config.scopes.all,
              hint: 'openid is what makes this an OIDC login and produces an id_token. ' \
                    'Leave empty to grant the default scopes.'

      if f.object.new_record?
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

  member_action :rotate_secret, method: :put do
    resource.renew_secret
    resource.save!
    redirect_to resource_path(resource), notice: 'Client secret rotated. The client must be reconfigured with the new one.'
  end

  action_item :rotate_secret, only: :show do
    if authorized?(:rotate_secret)
      link_to 'Rotate secret',
              { action: :rotate_secret, id: resource.id },
              method: :put,
              data: { confirm: 'Replace this client secret? The client stops being able to ' \
                               'obtain new tokens until it is reconfigured.' }
    end
  end
end
