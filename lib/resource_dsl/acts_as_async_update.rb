# When including this module without acts_as_async_destroy, add following strings to resource register file:
# config.batch_actions = true
# config.scoped_collection_actions_if = -> { true }

module ResourceDSL
  module ActsAsAsyncUpdate
    def acts_as_async_update(model_class, attrs_to_update)
      scoped_collection_action :async_update,
                               title: 'Update batch',
                               class: 'scoped_collection_action_button ui',
                               form: attrs_to_update do
        Delayed::Job.enqueue AsyncBatchUpdateJob.new(model_class,
                                                     scoped_collection_records.except(:eager_load).to_sql,
                                                     params[:changes]),
                             queue: 'batch_actions'
        flash[:notice] = I18n.t('flash.actions.batch_actions.batch_update.job_scheduled')
        head :ok
      end
    end

    def boolean_select
      [ ['Yes', 't'], ['No', 'f'] ]
    end

  end
end
