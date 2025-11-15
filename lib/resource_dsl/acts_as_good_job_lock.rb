# frozen_string_literal: true

module ResourceDSL
  module ActsAsGoodJobLock
    def acts_as_good_job_lock
      controller do
        def update
          if GoodJob::Job.where(queue_name: :batch_actions, error: nil).any?
            flash[:error] = I18n.t('flash.actions.batch_actions.editing_prohibited')
            redirect_to action: :show
          else
            super
          end
        end

        def destroy
          if GoodJob::Job.where(queue_name: :batch_actions, error: nil).any?
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
