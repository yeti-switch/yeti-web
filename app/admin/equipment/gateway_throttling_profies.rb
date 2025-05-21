# frozen_string_literal: true

ActiveAdmin.register Equipment::GatewayThrottlingProfile do
  menu parent: 'Equipment', priority: 81, label: 'Gateway Throttling Profile'

  search_support!
  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export  :id,
                  :name

  permit_params :name, :threshold, :window, codes: []

  index do
    selectable_column
    id_column
    actions
    column :name
    column :codes
    column :threshold
    column :window
  end

  filter :id
  filter :name

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :codes
      row :threshold
      row :window
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :codes,
              as: :select,
              include_blank: false,
              collection: Equipment::GatewayThrottlingProfile::CODES.invert,
              input_html: { class: 'chosen-sortable', multiple: true }
      f.input :threshold
      f.input :window
    end
    f.actions
  end
end
