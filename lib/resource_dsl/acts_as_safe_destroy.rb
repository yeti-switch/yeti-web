# frozen_string_literal: true

module ResourceDSL
  module ActsAsSafeDestroy
    def acts_as_safe_destroy
      batch_action :destroy, confirm: 'Are you sure?', if: proc { authorized?(:delete_all) } do |selected_ids|
        count = 0
        batch_action_collection.find(selected_ids).each do |record|
          authorize! ActiveAdmin::Auth::DESTROY, record
          count += 1 if destroy_resource(record)
        end
        redirect_to active_admin_config.route_collection_path(params),
                    notice: I18n.t('active_admin.batch_actions.succesfully_destroyed',
                                   count: "#{count}/#{selected_ids.count}",
                                   model: active_admin_config.resource_label.downcase,
                                   plural_model: active_admin_config.plural_resource_label(count: selected_ids.count).downcase)
      rescue StandardError => e
        flash[:error] = e.message
        CaptureError.capture(e, extra: { selected_ids: selected_ids })
        redirect_back fallback_location: root_path
      end
    end
  end
end
