# frozen_string_literal: true

ActiveAdmin.register System::ApiAccess, as: 'Api Access' do
  includes :customer
  menu parent: 'System', priority: 3
  config.batch_actions = false

  decorate_with ApiAccessDecorator

  permit_params :login,
                :password,
                :customer_id,
                :formtastic_allowed_ips,
                :allow_listen_recording,
                account_ids: []

  filter :id
  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true, ordered_by: :name } }

  filter :login

  index do
    selectable_column
    id_column
    actions
    column :login
    column :customer
    column :accounts do |r|
      ul class: 'ul-list-comma-separated' do
        r.accounts.map { |account| li auto_link(account) }
      end
    end
    column :allowed_ips
    column :allow_listen_recording
  end

  show do |r|
    attributes_table do
      row :id
      row :login
      row :customer
      row :accounts do
        ul do
          r.accounts.map { |account| li auto_link(account) }
        end
      end
      row :allowed_ips
      row :allow_listen_recording
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs do
      f.input :login, hint: link_to('Сlick to fill random login', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.input :password, as: :string, hint: link_to('Сlick to fill random password', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.contractor_input :customer_id, label: 'Customer', path_params: { q: { customer_eq: true } }
      f.account_input :account_ids,
                      multiple: true,
                      fill_params: { contractor_id_eq: f.object.customer_id },
                      fill_required: :contractor_id_eq,
                      input_html: {
                        'data-path-params': { 'q[contractor_id_eq]': '.customer_id-input' }.to_json,
                        'data-required-param': 'q[contractor_id_eq]'
                      }
      f.input :formtastic_allowed_ips, label: 'Allowed IPs',
                                       hint: 'Array of IP separated by comma'
      f.input :allow_listen_recording,
              as: :select,
              input_html: { class: 'chosen' },
              collection: [['Yes', true], ['No', false]]
    end
    f.actions
  end
end
