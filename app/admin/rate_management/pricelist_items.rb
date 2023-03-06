# frozen_string_literal: true

ActiveAdmin.register RateManagement::PricelistItem, as: 'Pricelist Item' do
  menu false
  actions :index
  decorate_with RateManagementPricelistItemDecorator
  belongs_to :rate_management_pricelist, parent_class: RateManagement::Pricelist

  controller do
    def scoped_collection
      super.preload(
        :routing_group,
        :vendor,
        :account,
        :routeset_discriminator,
        :gateway,
        :gateway_group,
        :routing_tag_mode,
        dialpeer: %i[
          gateway
          gateway_group
          routing_tag_mode
        ]
      )
    end

    # @see InheritedResources::BelongsToHelpers#parent
    def parent
      return @parent if defined?(@parent)

      parent_model = association_chain[-1]
      @parent = parent_model ? RateManagementPricelistDecorator.decorate(parent_model) : nil
    end
  end

  filter :dialpeer_id_eq, label: 'Dialpeer ID'
  filter :prefix
  acts_as_filter_by_routing_tag_ids routing_tag_ids_count: true
  filter :initial_rate
  filter :next_rate
  filter :connect_fee
  filter :initial_interval
  filter :next_interval
  filter :dst_number_min_length
  filter :dst_number_max_length
  boolean_filter :enabled
  filter :priority
  filter :valid_from
  boolean_filter :valid_from_null, label: 'Valid From NOW'

  sidebar 'Rate Management Pricelist', only: :index, priority: 0 do
    attributes_table_for(helpers.parent) do
      row :id
      row :name
      row :project
      row :state, &:state_badge
      row :background_job, &:background_job_badge
      row :dialpeers, &:dialpeers_link
      row :retain_enabled
      row :retain_priority
      row :valid_till
      row :applied_at if helpers.parent.applied?
      row :created_at
    end
  end

  action_item :detect_dialpeers do
    if authorized?(:detect_dialpeers) && helpers.parent.new? && !helpers.parent.has_background_job?
      link_to 'Detect Dialpeers',
              detect_dialpeers_rate_management_pricelist_path(helpers.parent)
    end
  end

  action_item :redetect_dialpeers do
    if authorized?(:redetect_dialpeers) && helpers.parent.dialpeers_detected? && !helpers.parent.has_background_job?
      link_to 'Redetect Dialpeers',
              redetect_dialpeers_rate_management_pricelist_path(helpers.parent)
    end
  end

  action_item :apply_changes do
    if authorized?(:apply_changes) && helpers.parent.dialpeers_detected? && !helpers.parent.has_background_job? && !helpers.parent.items.with_error.exists?
      link_to 'Apply Changes',
              apply_changes_rate_management_pricelist_path(helpers.parent),
              data: { confirm: 'Are you sure you want to start Apply Changes?' }
    end
  end

  action_item :edit do
    if authorized?(:update)
      link_to 'Edit Pricelist',
              edit_rate_management_pricelist_path(helpers.parent)
    end
  end

  action_item :destroy do
    if authorized?(:remove)
      link_to 'Delete Pricelist',
              rate_management_pricelist_path(helpers.parent),
              method: :delete,
              data: { confirm: I18n.t('active_admin.delete_confirmation') }
    end
  end

  before_action do
    if helpers.parent.dialpeers_detected? && helpers.parent.detect_dialpeers_in_progress?
      flash[:warning] = 'Redetect Dialpeers background job is in progress'
    elsif helpers.parent.detect_dialpeers_in_progress?
      flash[:warning] = 'Detect Dialpeers background job is in progress'
    elsif helpers.parent.apply_changes_in_progress?
      flash[:warning] = 'Apply Changes background job is in progress'
    elsif helpers.parent.items.with_error.exists?
      flash[:warning] = "Changes can't be applied because pricelist has error items"
    end
  end

  scope :all, default: true, if: -> { !parent.new? }
  scope :create, :to_create, if: -> { !parent.new? }
  scope :change, :to_change, if: -> { !parent.new? }
  scope :delete, :to_delete, if: -> { !parent.new? }
  scope :error, :with_error, if: -> { parent.dialpeers_detected? }

  index do
    column :id
    unless helpers.parent.new?
      column :type, &:type_badge
      column 'Dialpeer', &:link_to_dialpeer
    end
    column :prefix
    column :routing_tags
    column :initial_rate
    column :next_rate
    column :connect_fee
    column :initial_interval
    column :next_interval
    column :dst_number_min_length
    column :dst_number_max_length
    column :enabled
    column :priority
    column :vendor, &:link_to_vendor
    column :account, &:link_to_account
    column :routing_group, &:link_to_routing_group
    column :routeset_discriminator, &:link_to_routeset_discriminator
    column :gateway
    column :gateway_group
    column :exclusive_route
    column :acd_limit
    column :asr_limit
    column :capacity
    column :force_hit_rate
    column :lcr_rate_multiplier
    column :reverse_billing
    column :short_calls_limit
    column :valid_from
    column :valid_till
    column :src_name_rewrite_result
    column :src_name_rewrite_rule
    column :src_rewrite_result
    column :src_rewrite_rule
    column :dst_rewrite_result
    column :dst_rewrite_rule
  end

  csv do
    column :id
    column :type
    column(:dialpeer) { |r| r.detected_dialpeer_ids.join(', ') }
    column :prefix
    column :routing_tags, &:routing_tag_names
    column(:initial_rate) { |r| r.model.initial_rate }
    column(:next_rate) { |r| r.model.next_rate }
    column(:connect_fee) { |r| r.model.connect_fee }
    column(:initial_interval) { |r| r.model.initial_interval }
    column(:next_interval) { |r| r.model.next_interval }
    column(:dst_number_min_length) { |r| r.model.dst_number_min_length }
    column(:dst_number_max_length) { |r| r.model.dst_number_max_length }
    column(:enabled) { |r| r.model.enabled }
    column(:priority) { |r| r.model.priority }
    column(:vendor) { |r| r.model.vendor.display_name }
    column(:account) { |r| r.model.account.display_name }
    column(:routing_group) { |r| r.model.routing_group.display_name }
    column(:routeset_discriminator) { |r| r.model.routeset_discriminator.display_name }
    column(:gateway) { |r| r.model.gateway&.display_name }
    column(:gateway_group) { |r| r.model.gateway_group&.display_name }
    column(:exclusive_route) { |r| r.model.exclusive_route }
    column(:acd_limit) { |r| r.model.acd_limit }
    column(:asr_limit) { |r| r.model.asr_limit }
    column(:capacity) { |r| r.model.capacity }
    column(:force_hit_rate) { |r| r.model.force_hit_rate }
    column(:lcr_rate_multiplier) { |r| r.model.lcr_rate_multiplier }
    column(:reverse_billing) { |r| r.model.reverse_billing }
    column(:short_calls_limit) { |r| r.model.short_calls_limit }
    column(:valid_from) { |r| r.model.valid_from&.to_s(:db) }
    column(:valid_till) { |r| r.model.valid_till.to_s(:db) }
    column(:src_name_rewrite_result) { |r| r.model.src_name_rewrite_result }
    column(:src_name_rewrite_rule) { |r| r.model.src_name_rewrite_rule }
    column(:src_rewrite_result) { |r| r.model.src_rewrite_result }
    column(:src_rewrite_rule) { |r| r.model.src_rewrite_rule }
    column(:dst_rewrite_result) { |r| r.model.dst_rewrite_result }
    column(:dst_rewrite_rule) { |r| r.model.dst_rewrite_rule }
  end
end
