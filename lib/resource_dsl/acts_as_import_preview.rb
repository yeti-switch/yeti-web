# frozen_string_literal: true

module ResourceDSL
  module ActsAsImportPreview
    def acts_as_import_preview
      menu false

      # actions :all, except: :new
      actions :index, :destroy, :delete

      # All importing models must have decorator inherited from Importing::BaseDecorator.
      decorate_with "#{config.resource_class}Decorator"

      controller do
        def scoped_collection
          # Preload import_object and all associations from import_attributes
          # because we will have auto_link for all of them.
          assoc_names = resource_class.import_assoc_keys.map { |key| key.gsub(/_id\z/, '').to_sym }
          super.preload(:import_object, *assoc_names)
        end
      end

      scope :all
      scope :success
      scope :with_errors
      scope :for_create
      scope :for_update

      redirect_proc = proc do
        active_admin_config.namespace.resource_for(active_admin_config.resource_class.import_class).route_collection_path
      end

      acts_as_import_resource_class = config.resource_class

      action_item :create_new_once, only: [:index] do
        if authorized?(:batch_insert)
          link_to 'Create new ones', action: :batch_insert unless Importing::ImportingDelayedJob.jobs?
        end
      end

      action_item :create_and_update, only: [:index] do
        if authorized?(:batch_replace)
          link_to 'Create and update ', action: :batch_replace unless Importing::ImportingDelayedJob.jobs?
        end
      end

      action_item :only_update, only: [:index] do
        if authorized?(:batch_update)
          link_to 'Only update', action: :batch_update unless Importing::ImportingDelayedJob.jobs?
        end
      end

      action_item :cancel_import_session, only: [:index] do
        if authorized?(:destroy_all)
          link_to 'Cancel import session', action: :delete_all unless Importing::ImportingDelayedJob.jobs?
        end
      end

      action_item :apply_unique_columns, only: [:index] do
        if authorized?(:batch_update)
          if acts_as_import_resource_class.strict_unique_attributes.present?
            link_to 'Apply unique columns',
                    url_for(action: :apply_unique_columns),
                    class: 'modal-link',
                    data: {
                      method: :put,
                      hint: "Unique columns: #{acts_as_import_resource_class.strict_unique_attributes.join(', ')}",
                      inputs: {
                        additional_filter: :text
                      }.to_json
                    }
          else
            link_to 'Apply unique columns',
                    url_for(action: :apply_unique_columns),
                    class: 'modal-link',
                    data: {
                      method: :put,
                      inputs: {
                        additional_filter: :text,
                        unique_columns: [''] + acts_as_import_resource_class.import_attributes
                      }.to_json
                    }
          end
        end
      end

      collection_action :delete_all do
        authorize!
        acts_as_import_resource_class.delete_all
        redirect_to redirect_proc
      end

      collection_action :apply_unique_columns, method: :put do
        authorize!(:batch_update)
        if acts_as_import_resource_class.strict_unique_attributes.present?
          permitted_params = params.require(:changes).permit(:additional_filter)
          unique_columns = acts_as_import_resource_class.strict_unique_attributes
          extra_condition = permitted_params[:additional_filter]
        else
          permitted_params = params.require(:changes).permit(:additional_filter, unique_columns: [])
          unique_columns = permitted_params[:unique_columns].reject(&:blank?)
          extra_condition = permitted_params[:additional_filter]
        end
        begin
          acts_as_import_resource_class.resolve_object_id(unique_columns, extra_condition)
          flash[:notice] = 'Unique columns applied!'
        rescue Importing::Base::Error => e
          flash[:error] = e.message
        end
        redirect_back fallback_location: root_path
      end

      collection_action :batch_update do
        authorize!
        begin
          acts_as_import_resource_class.run_in_background(@paper_trail_info, :for_update)
          flash[:notice] = 'You have just run importing "Only update" in the background process, wait until it finishes'
        rescue Importing::Base::Error => e
          flash[:error] = e.message
        end
        redirect_back fallback_location: root_path
        #        redirect_to redirect_proc
      end

      collection_action :batch_replace do
        authorize!
        begin
          acts_as_import_resource_class.run_in_background(@paper_trail_info)
          flash[:notice] = 'You have just run importing "Create an update" in the background process, wait until it finishes'
        rescue Importing::Base::Error => e
          flash[:error] = e.message
        end
        #        redirect_to redirect_proc
        redirect_back fallback_location: root_path
      end

      collection_action :batch_insert do
        authorize!
        begin
          acts_as_import_resource_class.run_in_background(@paper_trail_info, :for_create)
          flash[:notice] = 'You have just run importing "Create new ones" in the background process, wait until it finishes'
        rescue Importing::Base::Error => e
          flash[:error] = e.message
        end
        #        redirect_to redirect_proc
        redirect_back fallback_location: root_path
      end

      before_action do
        if Importing::ImportingDelayedJob.jobs?
          flash.now[:warning] = 'Background process is already running, wait until they finish'
        end
        @paper_trail_info = { whodunnit: current_admin_user.id, controller_info: info_for_paper_trail }
      end
    end
  end
end
