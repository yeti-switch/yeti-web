# frozen_string_literal: true

ActiveAdmin.register System::ApiLogConfig, as: 'Api Log Config' do
  menu parent: 'System', priority: 3
  config.batch_actions = false
  actions :index, :create, :new, :destroy

  permit_params :controller

  filter :controller, as: :select, collection: proc { ApiControllers.list }, input_html: { class: 'tom-select' }

  index do
    actions
    column :controller
  end

  form do |f|
    f.inputs do
      f.input :controller, as: :select,
                           collection: ApiControllers.list,
                           input_html: { class: 'tom-select tom-select-wide' },
                           hint: 'Only controllers within "Api" namespace will be displayed.'
    end
    f.actions
  end
end
