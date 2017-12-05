module ResourceDSL
  module ActsAsAsyncDestroy

    def acts_as_async_destroy(model_class)
      config.batch_actions = true
      config.scoped_collection_actions_if = -> { true }
      batch_action :destroy, false #disable common batch delete

      scoped_collection_action :async_destroy,
                               title: 'Delete batch' do
        AsyncBatchDestroyJob.perform_later(model_class,
                                           scoped_collection_records.except(:eager_load).to_sql)
        flash[:notice] = I18n.t('flash.actions.batch_actions.batch_destroy.job_scheduled')
        head :ok
      end
    end

  end
end