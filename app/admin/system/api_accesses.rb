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
                account_ids: []

  filter :id
  filter :customer,
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search?q[customer_eq]=true&q[ordered_by]=name' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:customer_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         }

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
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :login, hint: link_to('Сlick to fill random login', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.input :password, as: :string, hint: link_to('Сlick to fill random password', 'javascript:void(0)', onclick: 'generateCredential(this)')
      f.input :customer, as: :select,
                         input_html: {
                           class: 'chosen',
                           onchange: remote_chosen_request(:get, with_contractor_accounts_path, { contractor_id: '$(this).val()' }, :system_api_access_account_ids, '')
                         }
      f.input :account_ids, as: :select, label: 'Accounts',
                            input_html: { class: 'chosen', multiple: true, 'data-placeholder': 'Choose an Account...' },
                            collection: (f.object.customer.nil? ? [] : f.object.customer.accounts.collection)
      f.input :formtastic_allowed_ips, label: 'Allowed IPs',
                                       hint: 'Array of IP separated by comma'
    end
    f.actions
  end
end
