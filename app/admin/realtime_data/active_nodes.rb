ActiveAdmin.register RealtimeData::ActiveNode do
  menu parent: "Realtime Data", label:"Nodes", priority: 10
  config.batch_actions = false
  config.sort_order = nil
  config.batch_actions = false
  config.paginate = false
  actions :index

  decorate_with ActiveNodeDecorator


  filter :name #, as: :select,  collection: proc { SbcNode.pluck(:name)}
  filter :pop

  # before_action do
  #   @index_partial = 'shared/active_calls_chart'
  #   @index_partial_title = 'Active Calls Chart'
  #end


  # index as: :table_with_partial do
  index do
    column :id, sortable: false
    column :name, sortable: false
    column :active_calls_count
    column :version
    column :shutdown_req_time
    column :sessions_num
    column :uptime
  end

end
