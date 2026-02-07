# frozen_string_literal: true

ActiveAdmin.register Routing::RateGroup do
  menu parent: 'Routing', label: 'Rate Groups', priority: 42

  acts_as_audit
  acts_as_clone_with_helper helper: Routing::RateGroupDuplicatorForm, name: 'Copy with destinations'
  acts_as_safe_destroy
  acts_as_export :id, :name
  acts_as_import resource_class: Importing::RateGroup

  permit_params :name, rateplan_ids: []

  includes :rateplans

  filter :id
  filter :name

  index do
    selectable_column
    id_column
    actions
    column :name
    column :rateplans
    column :external_id
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :rateplans
      row :external_id
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name
      f.input :rateplans,
              input_html: { class: 'tom-select-sortable', multiple: true },
              collection: Routing::Rateplan.order(:name)
    end
    f.actions
  end
end
