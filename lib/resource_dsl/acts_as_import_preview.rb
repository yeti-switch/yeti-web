module ResourceDSL
  module ActsAsImportPreview
    def acts_as_import_preview
      menu false

      #actions :all, except: :new
      actions :index, :destroy, :delete

      scope :all
      scope :success
      scope :with_errors
      scope :for_create
      scope :for_update

      redirect_proc = proc { config.namespace.resource_for(config.resource_class.import_class).route_collection_path }

      acts_as_import_resource_class = config.resource_class

      action_item :create_new_once, only: [:index] do
        link_to "Create new ones", action: :batch_insert unless Importing::ImportingDelayedJob.jobs?
      end

      action_item :create_and_update, only: [:index] do
        link_to "Create and update ", action: :batch_replace unless Importing::ImportingDelayedJob.jobs?
      end

      action_item :only_update, only: [:index] do
        link_to "Only update", action: :batch_update unless Importing::ImportingDelayedJob.jobs?
      end

      action_item :cancel_import_session, only: [:index] do
        link_to "Cancel import session", action: :delete_all unless Importing::ImportingDelayedJob.jobs?
      end

      collection_action :delete_all do
        acts_as_import_resource_class.delete_all
        redirect_to redirect_proc
      end

      collection_action :batch_update do
        acts_as_import_resource_class.run_in_background(@paper_trail_info, :for_update)
        flash[:notice] = 'You have just run importing "Only update" in the background process, wait until it finishes'
        redirect_to :back
#        redirect_to redirect_proc
      end

      collection_action :batch_replace do
        acts_as_import_resource_class.run_in_background(@paper_trail_info)
        flash[:notice] = 'You have just run importing "Create an update" in the background process, wait until it finishes'
#        redirect_to redirect_proc
        redirect_to :back
      end

      collection_action :batch_insert do
        acts_as_import_resource_class.run_in_background(@paper_trail_info, :for_create)
        flash[:notice] = 'You have just run importing "Create new once" in the background process, wait until it finishes'
#        redirect_to redirect_proc
        redirect_to :back
      end

      before_filter do
        if Importing::ImportingDelayedJob.jobs?
          flash.now[:warning] = 'Background process is already running, wait until they finish'
        end
        @paper_trail_info = { whodunnit: current_admin_user.id, controller_info: info_for_paper_trail }
      end

    end
  end
end
