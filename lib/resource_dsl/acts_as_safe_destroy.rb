# frozen_string_literal: true

module ResourceDSL
  module ActsAsSafeDestroy
    def acts_as_safe_destroy
      batch_action :destroy, confirm: 'Are you sure?', if: proc { authorized?(:delete_all) } do |selected_ids|
        batch_action_collection.find(selected_ids).each do |record|
          authorize! ActiveAdmin::Auth::DESTROY, record
          destroy_resource(record)
        end
        redirect_to active_admin_config.route_collection_path(params),
                    notice: I18n.t('active_admin.batch_actions.succesfully_destroyed',
                                   count: selected_ids.count,
                                   model: active_admin_config.resource_label.downcase,
                                   plural_model: active_admin_config.plural_resource_label(count: selected_ids.count).downcase)
      rescue StandardError => e
        flash[:error] = e.message
        redirect_back fallback_location: root_path
      end

      controller do
        # def batch_action_collection(*)
        #   find_collection(only: ActiveAdmin::BatchActions::Controller::COLLECTION_APPLIES - [:collection_decorator])
        # end

        def destroy
          # # resource = active_admin_config.resource_name.to_s.constantize.find(params[:id])
          # resource.destroy
          # flash[:notice] = "#{active_admin_config.resource_name.to_s.humanize} was successfully destroyed"
          # redirect_to action: "index"
          destroy!
        rescue StandardError => e
          logger.warn { e.message }
          flash[:error] = e.message
          redirect_to action: 'show', id: params[:id]
        end
      end
    end
  end
end
