ActiveAdmin.register Event do
  menu parent: "Logs", priority: 140
  actions :index, :show
  config.batch_actions = false

  index do
    id_column
    column :created_at
    column :node
    column :command
    column :updated_at
    column :retries
    column :last_error
  end

  filter :id
  filter :node, input_html: {class: 'chosen'}
  filter :retries
  filter :command

end
