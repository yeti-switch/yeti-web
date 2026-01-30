# frozen_string_literal: true

ActiveAdmin.register System::ApiAccess, as: 'Customer Portal Login' do
  includes :customer
  menu parent: 'System', priority: 3
  config.batch_actions = false

  acts_as_audit

  decorate_with ApiAccessDecorator

  permit_params :login,
                :password,
                :customer_id,
                :formtastic_allowed_ips,
                :allow_listen_recording,
                :provision_gateway_id,
                :customer_portal_access_profile_id,
                account_ids: [],
                allow_outgoing_numberlists_ids: []

  includes :customer, :provision_gateway, :customer_portal_access_profile

  filter :id
  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true, ordered_by: :name } }
  filter :login
  filter :allow_listen_recording
  filter :provision_gateway,
         input_html: { class: 'tom-select-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

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
    column :provision_gateway
    column :allow_outgoing_numberlists do |r|
      ul class: 'ul-list-comma-separated' do
        r.allow_outgoing_numberlists.map { |nl| li auto_link(nl) }
      end
    end
    column :customer_portal_access_profile
    column :created_at
    column :updated_at
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
      row :provision_gateway
      row :allow_outgoing_numberlists do
        ul do
          r.allow_outgoing_numberlists.map { |nl| li auto_link(nl) }
        end
      end
      row :customer_portal_access_profile
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs do
      f.input :login, hint: link_to('Сlick to fill random login', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.input :password, as: :string, hint: link_to('Сlick to fill random password', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.contractor_input :customer_id, label: 'Customer'
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
      f.input :allow_listen_recording
      f.input :customer_portal_access_profile, as: :select,
                                               input_html: { class: 'tom-select' },
                                               collection: System::CustomerPortalAccessProfile.all

      f.association_ajax_input :provision_gateway_id,
                               label: 'Provision Gateway',
                               scope: Gateway.order(:name),
                               path: '/gateways/search',
                               fill_params: { contractor_id_eq: f.object.customer_id },
                               input_html: {
                                 'data-path-params': { 'q[contractor_id_eq]': '.customer_id-input' }.to_json,
                                 'data-required-param': 'q[contractor_id_eq]'
                               }

      f.input :allow_outgoing_numberlists_ids,
              as: :select,
              collection: Routing::Numberlist.all,
              input_html: { class: 'tom-select', multiple: true }
    end
    f.actions
  end
end
