ActiveAdmin.register Routing::Blacklist, as: 'Blacklist' do

  menu parent: "Routing", priority: 110

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  includes :mode

  permit_params :name, :mode_id


  index do
    selectable_column
    id_column
    #actions
    actions do |row|
      link_to "Items", blacklist_routing_blacklist_items_path(row)
    end
    column :name
    column :mode
    column :created_at
    column :updated_at
  end

  show do |s|
    attributes_table do
      row :id
      row :name
      row :mode
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :mode
    end
    f.actions
  end

  filter :id
  filter :name
  filter :mode

end