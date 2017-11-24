module ResourceDSL
  module ActsAsAsyncUpdate

    def acts_as_async_update(model_class, attrs_to_update)
      scoped_collection_action :async_update,
                               title: 'Update batch',
                               class: 'scoped_collection_action_button ui',
                               form: -> do
                                 attrs_to_update
                               end do
        AsyncBatchUpdateJob.perform_later(model_class,
                                          scoped_collection_records.to_sql,
                                          params[:changes])
        flash[:notice] = I18n.t('flash.actions.batch_actions.batch_update.job_scheduled')
        head :ok
      end
    end

  end
end