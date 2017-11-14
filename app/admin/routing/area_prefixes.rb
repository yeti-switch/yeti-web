ActiveAdmin.register Routing::AreaPrefix do

  menu parent: "Routing", priority: 252, label: "Area Prefixes"

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :prefix, :area_id

  includes :area

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             {
                               area_id: Routing::Area.all.map{ |area| [area.name, area.id] }
                             }
                           end

  index do
    selectable_column
    id_column
    actions
    column :prefix
    column :area
  end

  show do |s|
    attributes_table do
      row :id
      row :prefix
      row :area
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :prefix
      f.input :area
    end
    f.actions
  end

  filter :id
  filter :prefix
  filter :area, input_html: {class: 'chosen'}

end