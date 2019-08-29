# frozen_string_literal: true

module ResourceDSL
  module WithGlobalDSL
    extend ActiveSupport::Concern

    included do
      private :apply_global_dsl!
    end

    def initialize(config)
      super(config)
      apply_global_dsl!
    end

    def apply_global_dsl!
      action_item(:new_on_show, only: :show) do
        if controller.action_methods.include?('new') && authorized?(:new, config.resource_class)
          localizer = ActiveAdmin::Localizers.resource(active_admin_config)
          link_to localizer.t(:new_model), new_resource_path
        end
      end
    end
  end
end
