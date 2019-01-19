# frozen_string_literal: true

module ActiveAdmin
  module IndexAsTableVisibleColumns
    module Controller
      extend ActiveSupport::Concern

      included do
        before_action only: :index do
          if columns_visibility?
            set_visible_columns
            @visible_columns = []
            if current_admin_user.visible_columns[visible_columns_key].is_a?(Array)
              @visible_columns = current_admin_user.visible_columns[visible_columns_key]
            end
          end
        end

        def set_visible_columns
          if request.xhr?
            # Set or clear values
            if params.key?(:index_table_visible_columns)
              visible_columns_storage = current_admin_user.visible_columns
              visible_columns_storage[visible_columns_key] = params[:index_table_visible_columns]
              current_admin_user.update_column(:visible_columns, visible_columns_storage)
              render(json: { visible_columns: visible_columns_storage[visible_columns_key] }) && return
            end
          end
        end

        protected

        def columns_visibility?
          false
        end

        def visible_columns_key
          # current_path = request.env['PATH_INFO']
          # current_route = Rails.application.routes.recognize_path(current_path)
          # current_route.sort.flatten.join('-').gsub(/\//, '_')
          @visible_columns_key ||= params['controller'].to_s
        end
      end
    end
  end
end

ActiveAdmin.before_load do |_app|
  # Add our Extensions
  ActiveAdmin::BaseController.send :include, ActiveAdmin::IndexAsTableVisibleColumns::Controller
end
