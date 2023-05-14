# frozen_string_literal: true

ActiveAdmin.register System::Country do
  actions :index, :show
  menu parent: 'System', label: 'Countries', priority: 120
  search_support!

  config.batch_actions = false

  filter :id
  filter :name
  filter :iso2

  index do
    id_column
    column :name
    column :iso2
  end
end
