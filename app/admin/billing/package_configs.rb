ActiveAdmin.register Billing::PackageConfig do
  menu parent: "Billing", priority: 23

  config.batch_actions = false

  permit_params :package_id, :prefix, :amount

  acts_as_export :id,
                 [:package_name, proc { |row| row.package.try(:name) }],
                 :prefix, :amount

  includes :package

  form do |f|
    f.inputs form_title do
      f.input :package
      f.input :prefix
      f.input :amount
    end
    f.actions
  end

  index do
    id_column
    actions
    column :package
    column :prefix
    column :amount
  end

  filter :id
  filter :name
  filter :package
  filter :prefix
  filter :amount


end
