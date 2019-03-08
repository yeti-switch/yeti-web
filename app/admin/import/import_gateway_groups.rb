# frozen_string_literal: true

ActiveAdmin.register Importing::GatewayGroup do

  filter :name
  filter :vendor, input_html: { class: 'chosen' }
  filter :balancing_mode, as: :select

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end

    def scoped_collection
      super.includes(:vendor, :balancing_mode)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id

    column :vendor, sortable: :vendor_name do |row|
      if row.vendor.blank?
        row.vendor_name
      else
        auto_link(row.vendor, row.vendor_name)
      end
    end

    column :name

    column :balancing_mode, sortable: :balancing_mode_name do |row|
      if row.balancing_mode.blank?
        row.balancing_mode_name
      else
        auto_link(row.balancing_mode, row.balancing_mode_name)
      end
    end

  end
end
