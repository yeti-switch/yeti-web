# frozen_string_literal: true

ActiveAdmin.register RealtimeData::ActiveNode do
  menu parent: 'Realtime Data', label: 'Nodes', priority: 10
  config.batch_actions = false
  config.sort_order = nil
  config.batch_actions = false
  config.paginate = false
  actions :index

  decorate_with ActiveNodeDecorator

  filter :name # , as: :select,  collection: proc { SbcNode.pluck(:name)}
  filter :pop

  index do
    column :id, sortable: false
    column :name, sortable: false
    column :active_calls_count
    column :version
    column :core_version
    column :shutdown_req_time
    column :sessions_num
    column :uptime
  end
end
