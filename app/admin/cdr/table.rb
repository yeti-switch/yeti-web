# frozen_string_literal: true

ActiveAdmin.register Cdr::Table, as: 'CdrTable' do
  menu parent: 'CDR', label: 'Tables', priority: 10
  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'date_stop_desc'

  acts_as_audit

  member_action :unload, method: :get do
    resource.unload
    redirect_to cdr_tables_path
  end

  action_item :upload_files, only: :index do
    link_to 'Unloaded files', GuiConfig.cdr_unload_uri, method: :get
  end

  index do
    selectable_column
    id_column
    actions do |row|
      link_to 'Unload', unload_cdr_table_path(row), method: :get
    end
    column :name
    column :active
    column :date_start
    column :date_stop
    column :data_size, sortable: false do |row|
      number_to_human_size(row.table_data_size)
    end
    column :full_size, sortable: false do |row|
      number_to_human_size(row.table_full_size)
    end
  end

  filter :id
  filter :name
  filter :balance
  filter :active, as: :select, collection: [['Yes', true], ['No', false]]
end
