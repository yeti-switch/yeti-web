ActiveAdmin.register System::ApiLogConfig, as: 'Api Log Config' do
  menu parent: "System",  priority: 3
  config.batch_actions = false
  actions :index, :update

  permit_params :debug

  filter :controller

  index do
    column :controller
    boolean_edit_column :debug
  end
end
