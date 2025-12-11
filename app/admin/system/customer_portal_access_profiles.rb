# frozen_string_literal: true

ActiveAdmin.register System::CustomerPortalAccessProfile, as: 'Customer Portal Access Profiles' do
  menu parent: 'System', priority: 5

  actions :index, :show, :edit, :update, :destroy, :create, :new

  permit_params :name,
                :account,
                :outgoing_rateplans,
                :outgoing_cdrs,
                :outgoing_cdr_exports,
                :outgoing_statistics,
                :outgoing_statistics_active_calls,
                :outgoing_statistics_acd,
                :outgoing_statistics_asr,
                :outgoing_statistics_failed_calls,
                :outgoing_statistics_successful_calls,
                :outgoing_statistics_total_calls,
                :outgoing_statistics_total_duration,
                :outgoing_statistics_total_price,
                :outgoing_statistics_acd_value,
                :outgoing_statistics_asr_value,
                :outgoing_statistics_failed_calls_value,
                :outgoing_statistics_successful_calls_value,
                :outgoing_statistics_total_calls_value,
                :outgoing_statistics_total_duration_value,
                :outgoing_statistics_total_price_value,
                :outgoing_numberlists,
                :incoming_cdrs,
                :incoming_statistics,
                :incoming_statistics_active_calls,
                :incoming_statistics_acd,
                :incoming_statistics_asr,
                :incoming_statistics_failed_calls,
                :incoming_statistics_successful_calls,
                :incoming_statistics_total_calls,
                :incoming_statistics_total_duration,
                :incoming_statistics_total_price,
                :incoming_statistics_acd_value,
                :incoming_statistics_asr_value,
                :incoming_statistics_failed_calls_value,
                :incoming_statistics_successful_calls_value,
                :incoming_statistics_total_calls_value,
                :incoming_statistics_total_duration_value,
                :incoming_statistics_total_price_value,
                :invoices,
                :payments,
                :payments_cryptomus,
                :services,
                :transactions

  filter :id
  filter :name, as: :string

  index do
    id_column
    actions
    column :name
    column :created_at
    column :updated_at
  end

  show do |_c|
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
      row :account
      row :outgoing_rateplans
      row :outgoing_cdrs
      row :outgoing_cdr_exports
      row :outgoing_statistics
      row :outgoing_statistics_active_calls
      row :outgoing_statistics_acd
      row :outgoing_statistics_asr
      row :outgoing_statistics_failed_calls
      row :outgoing_statistics_successful_calls
      row :outgoing_statistics_total_calls
      row :outgoing_statistics_total_duration
      row :outgoing_statistics_total_price
      row :outgoing_statistics_acd_value
      row :outgoing_statistics_asr_value
      row :outgoing_statistics_failed_calls_value
      row :outgoing_statistics_successful_calls_value
      row :outgoing_statistics_total_calls_value
      row :outgoing_statistics_total_duration_value
      row :outgoing_statistics_total_price_value
      row :outgoing_numberlists
      row :incoming_cdrs
      row :incoming_statistics
      row :incoming_statistics_active_calls
      row :incoming_statistics_acd
      row :incoming_statistics_asr
      row :incoming_statistics_failed_calls
      row :incoming_statistics_successful_calls
      row :incoming_statistics_total_calls
      row :incoming_statistics_total_duration
      row :incoming_statistics_total_price
      row :incoming_statistics_acd_value
      row :incoming_statistics_asr_value
      row :incoming_statistics_failed_calls_value
      row :incoming_statistics_successful_calls_value
      row :incoming_statistics_total_calls_value
      row :incoming_statistics_total_duration_value
      row :incoming_statistics_total_price_value
      row :invoices
      row :payments
      row :payments_cryptomus
      row :services
      row :transactions
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :account
      f.input :outgoing_rateplans
      f.input :outgoing_cdrs
      f.input :outgoing_cdr_exports
      f.input :outgoing_statistics
      f.input :outgoing_statistics_active_calls
      f.input :outgoing_statistics_acd
      f.input :outgoing_statistics_asr
      f.input :outgoing_statistics_failed_calls
      f.input :outgoing_statistics_successful_calls
      f.input :outgoing_statistics_total_calls
      f.input :outgoing_statistics_total_duration
      f.input :outgoing_statistics_total_price
      f.input :outgoing_statistics_acd_value
      f.input :outgoing_statistics_asr_value
      f.input :outgoing_statistics_failed_calls_value
      f.input :outgoing_statistics_successful_calls_value
      f.input :outgoing_statistics_total_calls_value
      f.input :outgoing_statistics_total_duration_value
      f.input :outgoing_statistics_total_price_value
      f.input :outgoing_numberlists
      f.input :incoming_cdrs
      f.input :incoming_statistics
      f.input :incoming_statistics_active_calls
      f.input :incoming_statistics_acd
      f.input :incoming_statistics_asr
      f.input :incoming_statistics_failed_calls
      f.input :incoming_statistics_successful_calls
      f.input :incoming_statistics_total_calls
      f.input :incoming_statistics_total_duration
      f.input :incoming_statistics_total_price
      f.input :incoming_statistics_acd_value
      f.input :incoming_statistics_asr_value
      f.input :incoming_statistics_failed_calls_value
      f.input :incoming_statistics_successful_calls_value
      f.input :incoming_statistics_total_calls_value
      f.input :incoming_statistics_total_duration_value
      f.input :incoming_statistics_total_price_value
      f.input :invoices
      f.input :payments
      f.input :payments_cryptomus
      f.input :services
      f.input :transactions
    end
    f.actions
  end
end
