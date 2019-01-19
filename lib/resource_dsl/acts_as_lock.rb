# frozen_string_literal: true

module ResourceDSL
  module ActsAsLock
    def acts_as_lock
      member_action :unlock do
        resource.unlock
        flash[:notice] = "#{active_admin_config.resource_label} unlocked"
        redirect_back fallback_location: root_path
      end

      action_item :unlock, only: %i[show edit] do
        if resource.locked && authorized?(:unlock)
          link_to 'Unlock', action: :unlock, id: resource.id
        end
      end
    end
  end
end
