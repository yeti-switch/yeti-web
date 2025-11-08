# frozen_string_literal: true

module ResourceDSL
  # When including this module without acts_as_async_destroy, add following strings to resource register file:
  # config.batch_actions = true
  # config.scoped_collection_actions_if = -> { true }
  module ActsAsAsyncUpdate
    def acts_as_async_update(form_class)
      config.batch_actions = true
      config.scoped_collection_actions_if = -> { authorized?(:batch_update, resource_class) || authorized?(:batch_destroy, resource_class) }
      scoped_collection_action :async_update,
                               title: 'Update batch',
                               class: 'scoped_collection_action_button ui',
                               form: -> { form_class.form_data },
                               if: proc { authorized?(:batch_update, resource_class) } do
        attrs = params[:changes]&.permit!
        # if there is no changes just reload page quietly
        if attrs.present?
          form = form_class.new(attrs)
          form.selected_record = params[:collection_selection] if params[:collection_selection].present?
          if form.valid?
            form.perform(scoped_collection_records.except(:eager_load).to_sql, @paper_trail_info)
            flash[:notice] = I18n.t('flash.actions.batch_actions.batch_update.job_scheduled')
          else
            flash[:error] = "Validation Error: #{form.errors.full_messages.to_sentence}"
          end
        end
        head 200
      end

      before_action do
        @paper_trail_info = { whodunnit: current_admin_user.id, controller_info: info_for_paper_trail }
      end
    end
  end
end
