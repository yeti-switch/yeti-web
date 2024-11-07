# frozen_string_literal: true

ActiveAdmin.register Billing::ServiceType, as: 'ServiceType' do
  menu parent: %w[Billing Settings], label: 'Service Types', priority: 100

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :provisioning_class,
                 :variables,
                 :force_renew

  filter :id
  filter :name
  filter :provisioning_class
  filter :force_renew

  index do
    selectable_column
    id_column
    actions
    column :name
    column :force_renew
    column :provisioning_class
    column :variables, :variables_json
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :name
          row :force_renew
          row :provisioning_class
          row :services do
            link_to resource.services.count,
                    services_path(q: { type_id_eq: resource.id })
          end
        end
      end

      column do
        panel 'Variables' do
          pre code JSON.pretty_generate(resource.variables)
        end
      end
    end
  end

  permit_params :name, :provisioning_class, :force_renew, :variables_json

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name
      f.input :force_renew
      f.input :provisioning_class, as: :select, collection: Billing::ServiceType.available_provisioning_classes, input_html: { class: :chosen }
      f.input :variables_json, label: 'Variables', as: :text
    end
    f.actions
  end
end
