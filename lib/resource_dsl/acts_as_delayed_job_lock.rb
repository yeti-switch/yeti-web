# frozen_string_literal: true

module ResourceDSL
  module ActsAsDelayedJobLock
    def acts_as_delayed_job_lock
      controller do
        def update
          if Delayed::Job.where(queue: :batch_actions, failed_at: nil).any?
            flash[:error] = I18n.t('flash.actions.batch_actions.editing_prohibited')
            redirect_to action: :show
          else
            super
          end
        end

        def destroy
          if Delayed::Job.where(queue: :batch_actions, failed_at: nil).any?
            flash[:error] = I18n.t('flash.actions.batch_actions.destroying_prohibited')
            redirect_back fallback_location: root_path
          else
            super
          end
        end
      end
    end
  end
end
