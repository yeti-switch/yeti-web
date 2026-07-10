# frozen_string_literal: true

module ResourceDSL
  module ReportScheduler
    def report_scheduler(klass)
      action_item :create_scheduler, only: :index do
        action_item_link('Create scheduler', active_admin_resource_for(klass).route_collection_path + '/new')
      end

      action_item :schedulers, only: :index do
        n = klass.count
        action_item_link "Schedulers(#{n})", active_admin_resource_for(klass).route_collection_path unless n == 0
      end
    end

    def for_report(klass)
      action_item :reports, only: :index do
        action_item_link 'Reports', active_admin_resource_for(klass).route_collection_path
      end
    end
  end
end
