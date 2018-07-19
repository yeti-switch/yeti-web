module ResourceDSL
  module ActsAsStatus


    def acts_as_status


      scope :all, default: true
      scope :enabled
      scope :disabled


      batch_action :enable , confirm: "Are you sure?"  do |selection|

        active_admin_config.resource_class.find(selection).each do |resource|
          resource.enable!
        end
        redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are enabled!"
      end

      batch_action :disable, confirm: "Are you sure?"  do |selection|

        active_admin_config.resource_class.find(selection).each do |resource|
          resource.disable!
        end
        redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are disabled!"
      end


      member_action :enable do
        resource = active_admin_config.resource_class.find(params[:id])
        if authorized? :change_state, resource
          resource.enabled = true
          resource.save!
          flash[:notice] = "#{active_admin_config.resource_label} was successfully enabled"
        end
        redirect_back fallback_location: root_path
      end


      member_action :disable do
        resource = active_admin_config.resource_class.find(params[:id])
        if authorized? :change_state, resource
          resource.enabled = false
          resource.save!
          flash[:notice] = "#{active_admin_config.resource_label} was successfully disabled"
        end
        redirect_back fallback_location: root_path
      end


      action_item :enable, only: [:show, :edit] do
        if resource.disabled? and authorized? :change_state, resource and (!resource.respond_to?(:live?) or resource.live?)
          link_to "Enable", action: :enable, id: resource.id
        end
      end

      action_item :disable, only: [:show, :edit] do
        if resource.enabled? and authorized? :change_state, resource and (!resource.respond_to?(:live?) or resource.live?)
          link_to "Disable ", action: :disable, id: resource.id
        end


      end


    end

  end
end
