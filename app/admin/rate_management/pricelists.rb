# frozen_string_literal: true

ActiveAdmin.register RateManagement::Pricelist, as: 'Rate Management Pricelist' do
  menu parent: 'Rate Management', priority: 2, label: 'Pricelists'
  config.batch_actions = true
  actions :index, :new, :create, :edit, :update, :destroy
  decorate_with RateManagementPricelistDecorator

  controller do
    def build_new_resource
      RateManagement::PricelistForm.new(*resource_params)
    end

    def create
      super do |success, _|
        success.html { redirect_to rate_management_pricelist_pricelist_items_path(resource.model) }
      end
    end

    def destroy_resource(object)
      run_destroy_callbacks object do
        RateManagement::BulkDeletePricelists.call(pricelist_ids: [object.id])
      end
    end
  end

  batch_action :destroy, confirm: 'Are you sure?', if: proc { authorized?(:destroy) } do |pricelist_ids|
    RateManagement::BulkDeletePricelists.call(pricelist_ids: pricelist_ids)
    flash[:notice] = 'Selected Pricelists Destroyed!'
    redirect_to_back
  end

  filter :name
  filter :project_id, as: :select, collection: -> { RateManagement::Project.ordered }, input_html: { class: 'chosen' }
  filter :state_id, as: :select, collection: -> { RateManagement::Pricelist::CONST::STATE_IDS.invert }, input_html: { class: 'chosen' }
  filter :filename
  boolean_filter :retain_enabled
  boolean_filter :retain_priority
  filter :valid_from, as: :date_time_range
  filter :valid_till, as: :date_time_range
  filter :created_at, as: :date_time_range
  filter :updated_at, as: :date_time_range

  includes :project

  scope :in_progress, default: true
  scope :applied
  scope :all

  member_action :detect_dialpeers, method: :get do
    RateManagement::EnqueueDetectDialpeers.call(pricelist: resource)
    flash[:notice] = 'Process of detect dialpeers started. Wait few minutes!'
    redirect_to rate_management_pricelist_pricelist_items_path(resource.id)
  rescue RateManagement::EnqueueDetectDialpeers::Error => e
    flash[:error] = e.message
    redirect_to rate_management_pricelist_pricelist_items_path(resource)
  end

  member_action :redetect_dialpeers, method: :get do
    RateManagement::EnqueueRedetectDialpeers.call(pricelist: resource)
    flash[:notice] = 'Process of redetect dialpeers started. Wait few minutes!'
    redirect_to rate_management_pricelist_pricelist_items_path(resource)
  rescue RateManagement::EnqueueRedetectDialpeers::Error => e
    flash[:error] = e.message
    redirect_to rate_management_pricelist_pricelist_items_path(resource)
  end

  member_action :apply_changes, method: :get do
    RateManagement::EnqueueApplyChanges.call(pricelist: resource)
    flash[:notice] = 'Process of apply changes started. Wait few minutes!'
    redirect_to rate_management_pricelist_pricelist_items_path(resource.id)
  rescue RateManagement::EnqueueApplyChanges::Error => e
    flash[:error] = e.message
    redirect_to rate_management_pricelist_pricelist_items_path(resource)
  end

  index do
    selectable_column
    column :id
    actions do |r|
      r.link_to_items + r.dialpeers_link
    end
    column :name
    column :project
    column :state, sortable: :state_id, &:state_badge
    column :background_job, &:background_job_badge
    column :filename
    column :retain_enabled
    column :retain_priority
    column :valid_from
    column :valid_till
    column :applied_at
    column :created_at
    column :updated_at
  end

  permit_params do
    attrs = [:name]
    if get_resource_ivar&.persisted?
      attrs += [:filename]
    else
      attrs += %i[file valid_till valid_from project_id retain_enabled retain_priority]
    end
    attrs
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
      if f.object.persisted?
        f.input :filename
      else
        f.input :project_id, as: :select,
                             collection: RateManagement::Project.ordered,
                             input_html: { class: 'chosen' }
        f.input :valid_from, as: :date_time_picker
        f.input :valid_till, as: :date_time_picker
        f.input :file,
                as: :file,
                hint: "Allowed headers: #{RateManagement::PricelistItemsParser.humanized_headers.join(', ')}"

        f.input :retain_enabled,
                as: :select,
                collection: [['Yes', true], ['No', false]],
                include_blank: false,
                input_html: { class: 'chosen' },
                hint: 'Retain Enabled from Dialpeer for items with type CHANGE'

        f.input :retain_priority,
                as: :select,
                collection: [['Yes', true], ['No', false]],
                include_blank: false,
                input_html: { class: 'chosen' },
                hint: 'Retain Priority from Dialpeer for items with type CHANGE'
      end
    end
    f.actions
  end
end
