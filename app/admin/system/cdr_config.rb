# frozen_string_literal: true

ActiveAdmin.register System::CdrConfig do
  menu parent: 'System', priority: 121, label: 'CDR writer configuration'
  actions :index, :show, :edit, :update
  config.batch_actions = false
  config.filters = false

  acts_as_audit

  controller do
    def index
      redirect_to system_cdr_config_path(1)
    end
  end

  includes :call_duration_round_mode, :customer_price_round_mode, :vendor_price_round_mode

  permit_params :call_duration_round_mode_id,
                :customer_amount_round_mode_id, :customer_amount_round_precision,
                :vendor_amount_round_mode_id, :vendor_amount_round_precision

  show do |_config|
    attributes_table do
      row :call_duration_round_mode
      row :customer_price_round_mode
      row :customer_amount_round_precision
      row :vendor_price_round_mode
      row :vendor_amount_round_precision
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :call_duration_round_mode, as: :select, include_blank: false
      f.input :customer_price_round_mode, as: :select, include_blank: false
      f.input :customer_amount_round_precision
      f.input :vendor_price_round_mode, as: :select, include_blank: false
      f.input :vendor_amount_round_precision
    end
    f.actions
  end
end
