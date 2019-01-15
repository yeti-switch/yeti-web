# frozen_string_literal: true

ActiveAdmin.register Pop do
  menu parent: 'System', priority: 119
  config.batch_actions = false

  permit_params :name

  filter :name

  index do
    id_column
    actions
    column :name
  end
end
