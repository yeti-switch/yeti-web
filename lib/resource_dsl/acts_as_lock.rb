module ResourceDSL
  module ActsAsLock

    def acts_as_lock
      member_action :unlock do
        #todo  cancan support   ?
        if can? :manage, resource
          resource = active_admin_config.resource_class.find(params[:id])
          resource.unlock
          flash[:notice] = "#{active_admin_config.resource_label} unlocked"
        end
        redirect_to(:back)
      end

      action_item :unlock, only: [:show, :edit] do
        if resource.locked && can?(:manage, resource)
          link_to 'Unlock', action: :unlock, id: resource.id
        end
      end

    end

  end
end
