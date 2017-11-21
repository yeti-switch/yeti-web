module ResourceDSL
  module ActsAsAsyncUpdate

    def acts_as_async_update(model_name, attrs_to_update)
      scoped_collection_action :async_update,
                               title: 'Update batch',
                               class: 'scoped_collection_action_button ui',
                               form: -> do
                                 attrs_to_update
                               end do
        AsyncBatchUpdateJob.perform_later(model_name,
                                          scoped_collection_records.to_sql,
                                          params[:changes])
        flash[:notice] = 'Batch Update is scheduled'
        head :ok
      end
    end

  end
end