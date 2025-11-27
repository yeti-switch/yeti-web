# frozen_string_literal: true

require 'active_admin'

module ActiveAdmin
  module TomSelect
    # @api private
    class Engine < ::Rails::Engine
      engine_name 'activeadmin_tom_select'

      initializer 'activeadmin_tom_select.setup' do |app|
        app.config.to_prepare do
          # Load filter-related files patch
          require 'activeadmin/filter_builder'
          require 'activeadmin/filter_block'

          # Load input-related files patch
          require 'activeadmin/input_builder'
          require 'activeadmin/input_block'

          # Only prepend if ActiveAdmin is present and the target module exists
          if defined?(ActiveAdmin) && defined?(ActiveAdmin::Filters::DSL)
            ActiveAdmin::Filters::DSL.prepend(ActiveAdminFilterBlock)
          end

          # Prepend input block support to ActiveAdmin::Views::ActiveAdminForm
          if defined?(ActiveAdmin) && defined?(ActiveAdmin::Views::ActiveAdminForm)
            ActiveAdmin::Views::ActiveAdminForm.prepend(ActiveAdminInputBlock)
          end
        end

        ActiveSupport.on_load(:active_admin) do
          require 'activeadmin/inputs/tom_select_input'
          require 'activeadmin/inputs/filters/tom_select_input'
          require 'activeadmin/inputs/searchable_select_input'
          require 'activeadmin/inputs/filters/searchable_select_input'
        end
      end
    end
  end
end
