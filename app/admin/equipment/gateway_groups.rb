# frozen_string_literal: true

ActiveAdmin.register GatewayGroup do
  menu parent: 'Equipment', priority: 70

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('GatewayGroup')
  acts_as_async_update('GatewayGroup',
                       lambda do
                         {
                           vendor_id: Contractor.vendors.pluck(:name, :id),
                           prefer_same_pop: boolean_select
                         }
                       end)

  acts_as_delayed_job_lock

  acts_as_export :id, :name, [:vendor_name, proc { |row| row.vendor.try(:name) }], :prefer_same_pop
  acts_as_import resource_class: Importing::GatewayGroup

  decorate_with GatewayGroupDecorator

  permit_params :vendor_id, :name, :prefer_same_pop

  controller do
    def scoped_collection
      super.eager_load(:vendor)
    end
  end

  collection_action :with_contractor do
    @gr = Contractor.find(params[:contractor_id]).gateway_groups
    render plain: view_context.options_from_collection_for_select(@gr, :id, :display_name)
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :vendor do |c|
      auto_link(c.vendor, c.vendor.decorated_display_name)
    end
    column :prefer_same_pop
  end

  filter :id
  filter :name
  filter :vendor, input_html: { class: 'chosen' }
  filter :prefer_same_pop, as: :select, collection: [['Yes', true], ['No', false]]

  show do |s|
    attributes_table do
      row :id
      row :name
      row :vendor do
        auto_link(s.vendor, s.vendor.decorated_display_name)
      end
      row :prefer_same_pop
    end
    panel('Gateways in group') do
      table_for resource.gateways do |_g|
        column :id
        column :name
        column :host
        column :port
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :vendor, input_html: { class: 'chosen' }, collection: Contractor.vendors
      f.input :prefer_same_pop
    end
    f.actions
  end
end
