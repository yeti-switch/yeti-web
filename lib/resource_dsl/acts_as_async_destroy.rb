module ResourceDSL
  module ActsAsAsyncDestroy

    def acts_as_async_destroy(model_name)
      batch_action :destroy, false #disable common batch delete

      scoped_collection_action :async_destroy,
                               title: 'Delete batch' do
        AsyncBatchDestroyJob.perform_later(model_name,
                                           scoped_collection_records.to_sql)
        flash[:notice] = I18n.t('flash.actions.batch_destroy.job_scheduled')
        head :ok
      end
    end

  end
end