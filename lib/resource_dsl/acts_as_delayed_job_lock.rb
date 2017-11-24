module ResourceDSL
  module ActsAsDelayedJobLock

    def acts_as_delayed_job_lock
      controller do

        def update
          if Delayed::Job.where(queue: :batch_actions).any?
            flash[:error] = I18n.t('flash.actions.batch_actions.editing_prohibited')
            redirect_to action: :show
          else
            super
          end
        end

        def destroy
          if Delayed::Job.where(queue: :batch_actions).any?
            flash[:error] = I18n.t('flash.actions.batch_actions.destroying_prohibited')
            redirect_to :back
          else
            super
          end
        end

      end
    end

  end
end