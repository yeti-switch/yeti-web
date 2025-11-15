# frozen_string_literal: true

ActiveAdmin.register GatewayGroup do
  menu parent: 'Equipment', priority: 70
  search_support!
  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('GatewayGroup')
  acts_as_async_update BatchUpdateForm::GatewayGroup

  acts_as_good_job_lock

  acts_as_export  :id,
                  :name,
                  [:vendor_name, proc { |row| row.vendor.try(:name) }],
                  :balancing_mode_name,
                  :max_rerouting_attempts

  acts_as_import resource_class: Importing::GatewayGroup

  decorate_with GatewayGroupDecorator

  permit_params :vendor_id, :name, :balancing_mode_id, :max_rerouting_attempts

  controller do
    def scoped_collection
      super.eager_load(:vendor, :gateways)
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :vendor do |c|
      auto_link(c.vendor, c.vendor.decorated_display_name)
    end
    column :balancing_mode, &:balancing_mode_name
    column :max_rerouting_attempts
    column :gateways
  end

  filter :id
  filter :name
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }

  filter :balancing_mode_id, as: :select, collection: proc { GatewayGroup::BALANCING_MODES.invert }
  filter :max_rerouting_attempts

  show do |s|
    attributes_table do
      row :id
      row :name
      row :vendor do
        auto_link(s.vendor, s.vendor.decorated_display_name)
      end
      row :balancing_mode, &:balancing_mode_name
      row :max_rerouting_attempts
      row :gateways
    end
    panel('Gateways in group') do
      table_for resource.gateways.order(:priority) do |_g|
        column :id
        column :priority
        column :weight
        column :enabled
        column :name
        column :pop
        column :host
        column :port
        column :termination_capacity
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.contractor_input :vendor_id, label: 'Vendor', path_params: { q: { vendor_eq: true } }
      f.input :balancing_mode_id, as: :select, include_blank: false, collection: GatewayGroup::BALANCING_MODES.invert
      f.input :max_rerouting_attempts
    end
    f.actions
  end
end
