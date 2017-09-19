ActiveAdmin.register System::ApiAccess, as: 'Api Access' do
  menu parent: "System",  priority: 3
  config.batch_actions = false

  decorate_with ApiAccessDecorator

  permit_params :login,
                :password,
                :customer_id,
                :formtastic_allowed_ips,
                account_ids: []

  filter :id
  filter :customer, collection: proc { Contractor.select([:id, :name]).reorder(:name) }, input_html: { class: 'chosen' }
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
      f.input :login
      f.input :password
      f.input :customer, as: :select,
              input_html: {
                  class: 'chosen',
                  onchange: remote_chosen_request(:get, with_contractor_accounts_path, { contractor_id: "$(this).val()" }, :system_api_access_account_ids, '')
              }
      f.input :account_ids, as: :select, label: 'Accounts',
              input_html: { class: 'chosen', multiple: true, 'data-placeholder': "Choose an Account..." },
              collection: (f.object.customer.nil? ? [] : f.object.customer.accounts.collection)
      f.input :formtastic_allowed_ips, label: 'Allowd IPs',
              hint: 'Array of IP devided by comma'
    end
    f.actions
  end
end
