
module ResourceDSL
  module ActsAsAudit
    def acts_as_audit

      controller do
        def show

#           resource = active_admin_config.resource_class.find(params[:id])
#           instance_variable_name = active_admin_config.resource_class.model_name.route_key
          resource = active_admin_config.resource_class.find(params[:id])
          @last_version = resource.versions.last
          if params[:version]
            @version = resource.versions.find(params[:version])
          else
            @version = @last_version
          end
          if @version

            @next_version = @version.next
            @previous_version = @version.previous


            @versions_total_count = resource.versions.count
            resource = @next_version.reify if (params[:version] and @next_version)
          end

          if active_admin_config.decorator_class_name
            resource = apply_decorator(resource)
          end

          set_resource_ivar(resource)

          show!

        end
      end


      action_item :history, only: [:show, :edit] do

        link_to "History", action: :history, id: resource.id

      end

      member_action :history do
        resource = active_admin_config.resource_class.find(params[:id])
        #todo: add paginations
        #@versions = resource.versions.includes(:admin).reorder('id desc').limit(500)
        @versions = resource.versions.reorder('id desc').limit(500)
        render "layouts/history"
      end

      sidebar :history, partial: "layouts/version", only: :show

    end

  end

end
