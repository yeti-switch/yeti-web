# frozen_string_literal: true

module ResourceDSL
  module ActsAsStatus
    def acts_as_status(show_count: true)
      scope :all, default: true, show_count: show_count
      scope :enabled, show_count: show_count
      scope :disabled, show_count: show_count

      batch_action :enable, confirm: 'Are you sure?' do |selection|
        active_admin_config.resource_class.find(selection).each(&:enable!)
        redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are enabled!"
      end

      batch_action :disable, confirm: 'Are you sure?' do |selection|
        active_admin_config.resource_class.find(selection).each(&:disable!)
        redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are disabled!"
      end

      member_action :enable do
        resource.update!(enabled: true)
        flash[:notice] = "#{active_admin_config.resource_label} was successfully enabled"
        redirect_back fallback_location: root_path
      end

      member_action :disable do
        resource.update!(enabled: false)
        flash[:notice] = "#{active_admin_config.resource_label} was successfully disabled"
        redirect_back fallback_location: root_path
      end

      action_item :enable, only: %i[show edit] do
        if resource.disabled? && authorized?(:enable) && (!resource.respond_to?(:live?) || resource.live?)
          link_to 'Enable', action: :enable, id: resource.id
        end
      end

      action_item :disable, only: %i[show edit] do
        if resource.enabled? && authorized?(:disable) && (!resource.respond_to?(:live?) || resource.live?)
          link_to 'Disable ', action: :disable, id: resource.id
        end
      end
    end
  end
end
