# frozen_string_literal: true

ActiveAdmin.register CronJobInfo, as: 'Cron Job' do
  menu parent: 'System', priority: 100

  config.batch_actions = false
  actions :index, :show

  index do
    column :name
    column :last_success
    column :last_run_at
    column :last_duration
    column :cron_line
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :name
          row :last_success
          row :last_run_at
          row :last_duration
          row :cron_line
        end
      end

      column do
        panel 'Last Exception' do
          pre_wrap(resource.last_exception)
        end
      end
    end
  end
end
