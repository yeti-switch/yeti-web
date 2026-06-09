# frozen_string_literal: true

ActiveAdmin.register Cdr::CdrCompactedTable, as: 'Compacted Tables' do
  config.batch_actions = false # no destroy action, so the default batch Delete is hidden
  menu parent: 'CDR', priority: 96, label: 'Compacted Tables'

  actions :index

  filter :table_name
  filter :created_at

  index do
    id_column
    column :table_name
    column :created_at
  end
end
