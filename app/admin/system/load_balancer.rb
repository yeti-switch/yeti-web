ActiveAdmin.register System::LoadBalancer do
  actions :all
  menu parent: "System", label: "Load balancers", priority: 124
  config.batch_actions = false

  permit_params :name, :signalling_ip

  filter :id
  filter :name
  filter :signalling_ip

  index do
    id_column
    column :name
    column :signalling_ip
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys.uniq
    f.inputs form_title do
      f.input :name
      f.input :signalling_ip
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :signalling_ip
    end
  end

end