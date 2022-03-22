# frozen_string_literal: true

ActiveAdmin.register BackgroundTask do
  menu parent: 'System', priority: 20
  actions :index, :show
  decorate_with BackgroundTaskDecorator

  scope(:active, default: true)
  scope(:running)
  scope(:failed)
  scope(:pending)
  scope(:to_retry)
  scope(:all)

  index do
    id_column
    column :queue
    column :name
    column :args, :args_short
    column :priority
    column :attempts
    column :last_error, :last_error_short
    column :failed_at
    column :run_at
    column :created_at
    column :locked_by
    column :locked_at

    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :args, &:args_short
          row :priority
          row :attempts
          row :run_at
          row :last_error, &:last_error_short
          row :locked_at
          row :failed_at
          row :locked_by
          row :queue
          row :created_at
          row :updated_at
        end
      end

      tab :arguments do
        panel 'Arguments' do
          pre_wrap resource.args
        end
      end

      tab :handler do
        panel 'Handler' do
          pre_wrap resource.handler
        end
      end

      tab :last_error do
        panel 'Error' do
          pre_wrap resource.last_error
        end
      end

      tab :comments do
        active_admin_comments
      end
    end
  end
end
