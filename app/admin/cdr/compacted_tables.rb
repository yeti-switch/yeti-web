# frozen_string_literal: true

ActiveAdmin.register Cdr::CdrCompactedTable, as: 'Compacted Tables' do
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
