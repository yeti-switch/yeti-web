module ResourceDSL
  module ActsAsAsyncDestroy

    def acts_as_async_destroy(model_class)
      config.batch_actions = true
      config.scoped_collection_actions_if = -> { true }
      batch_action :destroy, false #disable common batch delete

      scoped_collection_action :async_destroy,
                               title: 'Delete batch' do
        Delayed::Job.enqueue AsyncBatchDestroyJob.new(model_class,
                                                      scoped_collection_records.except(:eager_load).to_sql,
                                                      @paper_trail_info),
                             queue: 'batch_actions'
        flash[:notice] = I18n.t('flash.actions.batch_actions.batch_destroy.job_scheduled')
        head :ok
      end

      before_filter do
        @paper_trail_info = { whodunnit: current_admin_user.id, controller_info: info_for_paper_trail }
      end
    end

  end
end
