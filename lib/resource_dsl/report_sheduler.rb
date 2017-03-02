module ResourceDSL
  module ReportScheduler

    def report_scheduler(klass)

      action_item :create_scheduler, only: :index do
        link_to("Create scheduler", active_admin_resource_for(klass).route_collection_path+"/new")
      end

      action_item :schedulers, only: :index do
        n=klass.count
        link_to "Schedulers(#{n})", active_admin_resource_for(klass).route_collection_path unless n==0
      end

    end

    def for_report(klass)
      action_item :reports, only: :index do
        link_to "Reports", active_admin_resource_for(klass).route_collection_path
      end
    end

  end
end

