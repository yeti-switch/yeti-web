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
                :outgoing_numberlists,
                :incoming_cdrs,
                :incoming_statistics,
                :invoices,
                :payments,
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
end
