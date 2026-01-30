# frozen_string_literal: true

ActiveAdmin.register Routing::AreaPrefix do
  menu parent: 'Routing', priority: 252, label: 'Area Prefixes'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :prefix, :batch_prefix, :area_id

  includes :area

  index do
    selectable_column
    id_column
    actions
    column :prefix
    column :area
  end

  show do |_s|
    attributes_table do
      row :id
      row :prefix
      row :area
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      if f.object.new_record? # allow multiple prefixes delimited by comma in NEW form.
        f.input :batch_prefix, label: 'Prefix'
      else
        f.input :prefix, label: 'Prefix'
      end
      f.input :area, as: :select, input_html: { class: 'tom-select' }
    end
    f.actions
  end

  filter :id
  filter :prefix
  filter :area, input_html: { class: 'tom-select' }
  filter :prefix_covers, as: :string
end
