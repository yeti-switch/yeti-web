module ResourceDSL
  module ActsAsAsyncDestroy

    def acts_as_async_destroy(model_name)
      scoped_collection_action :async_destroy,
                               title: 'Delete batch' do
        AsyncBatchDestroyJob.perform_later(model_name,
                                           scoped_collection_records.to_sql)
        flash[:notice] = 'Batch Delete is scheduled'
        head :ok
      end
    end

  end
end