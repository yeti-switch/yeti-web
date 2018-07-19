module ResourceDSL
  module ActsAsLock

    def acts_as_lock
      member_action :unlock do
        if authorized? :manage, resource
          resource = active_admin_config.resource_class.find(params[:id])
          resource.unlock
          flash[:notice] = "#{active_admin_config.resource_label} unlocked"
        end
        redirect_back fallback_location: root_path
      end

      action_item :unlock, only: [:show, :edit] do
        if resource.locked && authorized?(:manage, resource)
          link_to 'Unlock', action: :unlock, id: resource.id
        end
      end

    end

  end
end
