ActiveAdmin.register System::LnpResolver do
  actions :all
  menu parent: "System", label: "LNP resolvers", priority: 130
  config.batch_actions = false
  permit_params :name, :address, :port

  filter :id
  filter :name

  index do
    id_column
    column :name
    column :address
    column :port
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :address
      f.input :port
    end
    f.actions
  end

end