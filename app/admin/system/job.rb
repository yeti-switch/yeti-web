ActiveAdmin.register BaseJob, as: 'Job' do
  menu parent: "System",  priority: 100

  config.batch_actions = false
  actions :index, :run


  controller do
    def find_resource
      super.becomes(BaseJob)
    end

  end

  member_action :run, method: :put do
     begin
       BaseJob.launch!(resource.id)
       flash[:notice] = "Finished!"
       redirect_to action: :index
     rescue StandardError => e
       logger.warn e.message
       logger.warn e.backtrace.join("\n")
       flash[:warning] = e.message
       redirect_to action: :index
     end
  end

  member_action :unlock, method: :put do
      resource.release_lock!
      redirect_to action: :index
  end


  index do
    id_column
    actions
    column :type
    column :description
    column :executed  do  |row|
      time_ago_in_words(row.updated_at) << " ago"
    end
    column :running
    actions defaults: false do  |row|
      if row.running
        link_to('Unlock', unlock_job_path(row), method: :put,  data: { confirm: "Are you sure?" })
      else
        link_to('Run', run_job_path(row), method: :put,  data: { confirm: "Are you sure?" })
      end

    end

  end


end

