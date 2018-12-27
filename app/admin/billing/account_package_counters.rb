ActiveAdmin.register Billing::AccountPackageCounter do
  menu parent: "Billing", priority: 11, label: "Account package counters"

  config.batch_actions = false
  actions :index, :show

  acts_as_export :id,
                 [:account_name, proc { |row| row.account.try(:name) }],
                 :prefix, :amount

  includes :account

  filter :id
  filter :account
  filter :prefix
  filter :amount

  index do
    id_column
    actions
    column :account
    column :prefix
    column :amount
    column :expired_at
  end

  show do
    attributes_table do
      row :id
      row :prefix
      row :amount
      row :expired_at
    end
  end


end
