# frozen_string_literal: true

ActiveAdmin.register RateManagement::Project, as: 'Rate Management Project' do
  menu parent: 'Rate Management', priority: 1, label: 'Projects'
  config.batch_actions = false
  acts_as_audit
  decorate_with RateManagementProjectDecorator

  controller do
    # @see ActiveAdmin::ResourceController::DataAccess#save_resource
    def save_resource(object)
      AdvisoryLock::Yeti.with_lock(:rate_management) { super }
    end

    def destroy_resource(object)
      run_destroy_callbacks object do
        project = Draper.undecorate(object)
        RateManagement::DeleteProject.call(project: project)
      end
    end
  end

  filter :name
  filter :routing_group, input_html: { class: 'chosen' }
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }
  account_filter :account_id_eq
  filter :routeset_discriminator, input_html: { class: 'chosen' }
  filter :created_at, as: :date_time_range
  filter :updated_at, as: :date_time_range

  includes :routing_group, :vendor, :account, :routeset_discriminator

  index do
    column :id
    actions do |r|
      r.pricelists_link + r.dialpeers_link
    end
    column :name
    column :routing_group
    column :vendor
    column :account
    column :routeset_discriminator
    column :created_at
    column :updated_at
  end

  show do
    columns do
      column do
        attributes_table title: 'Project details' do
          row :id
          row :name
          row :pricelists, &:pricelists_link
          row :dialpeers, &:dialpeers_link
          row :keep_applied_pricelists_days
          row :created_at
          row :updated_at
        end

        attributes_table title: 'Scope attributes' do
          row :vendor
          row :account
          row :routeset_discriminator
          row :routing_group
        end
      end

      column do
        attributes_table title: 'Constant attributes' do
          row :enabled
          row :gateway
          row :gateway_group
          row :acd_limit
          row :asr_limit
          row :short_calls_limit
          row :capacity
          row :src_name_rewrite_result
          row :src_name_rewrite_rule
          row :src_rewrite_result
          row :src_rewrite_rule
          row :dst_number_max_length
          row :dst_number_min_length
          row :dst_rewrite_result
          row :dst_rewrite_rule
          row :initial_interval
          row :next_interval
          row :priority
          row :lcr_rate_multiplier
          row :exclusive_route
          row :force_hit_rate
          row :reverse_billing
          row :routing_tags do
            div style: 'white-space: break-spaces;' do
              resource.routing_tags
            end
          end
          row :routing_tag_mode
        end
      end
    end
  end

  permit_params :id, :name, :vendor_id, :account_id, :routeset_discriminator_id, :routing_group_id, :acd_limit,
                :asr_limit, :capacity, :dst_number_max_length, :dst_number_min_length, :dst_rewrite_result,
                :dst_rewrite_rule, :enabled, :exclusive_route, :force_hit_rate, :initial_interval, :routing_tag_mode_id,
                :keep_applied_pricelists_days, :lcr_rate_multiplier, :next_interval, :priority, :reverse_billing,
                :short_calls_limit, :src_name_rewrite_result, :src_name_rewrite_rule, :src_rewrite_result,
                :src_rewrite_rule, :gateway_group_id, :gateway_id, routing_tag_ids: []

  before_action only: :update do
    # Chosen multiple does not add parameter to payload when nothing selected.
    params[:rate_management_project][:routing_tag_ids] ||= []
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Project details' do
      f.input :name
      f.input :keep_applied_pricelists_days
    end

    f.inputs 'Scope attributes' do
      f.contractor_input :vendor_id, label: 'Vendor', path_params: { q: { vendor_eq: true } }
      f.account_input :account_id,
                      fill_params: { contractor_id_eq: f.object.vendor_id },
                      fill_required: :contractor_id_eq,
                      input_html: {
                        'data-path-params': { 'q[contractor_id_eq]': '.vendor_id-input' }.to_json,
                        'data-required-param': 'q[contractor_id_eq]'
                      }
      f.input :routeset_discriminator, include_blank: false, input_html: { class: 'chosen' }
      f.input :routing_group, include_blank: false, input_html: { class: 'chosen' }
    end

    f.inputs 'Constant attributes' do
      f.input :enabled,
              as: :select,
              collection: [['Yes', true], ['No', false]],
              include_blank: false,
              input_html: { class: 'chosen' }

      f.association_ajax_input :gateway_id,
                               label: 'Gateway',
                               scope: Gateway.order(:name),
                               path: '/gateways/search',
                               fill_params: { termination_contractor_id_eq: f.object.vendor_id },
                               fill_required: :termination_contractor_id_eq,
                               input_html: {
                                 'data-path-params': { 'q[termination_contractor_id_eq]': '.vendor_id-input' }.to_json,
                                 'data-required-param': 'q[termination_contractor_id_eq]'
                               }

      f.association_ajax_input :gateway_group_id,
                               label: 'Gateway Group',
                               scope: GatewayGroup.order(:name),
                               path: '/gateway_groups/search',
                               fill_params: { vendor_id_eq: f.object.vendor_id },
                               fill_required: :vendor_id_eq,
                               input_html: {
                                 'data-path-params': { 'q[vendor_id_eq]': '.vendor_id-input' }.to_json,
                                 'data-required-param': 'q[vendor_id_eq]'
                               }

      f.input :acd_limit
      f.input :asr_limit
      f.input :short_calls_limit
      f.input :capacity
      f.input :src_name_rewrite_result
      f.input :src_name_rewrite_rule
      f.input :src_rewrite_result
      f.input :src_rewrite_rule
      f.input :dst_number_min_length
      f.input :dst_number_max_length
      f.input :dst_rewrite_result
      f.input :dst_rewrite_rule
      f.input :initial_interval
      f.input :next_interval
      f.input :priority
      f.input :lcr_rate_multiplier

      f.input :exclusive_route,
              as: :select,
              collection: [['Yes', true], ['No', false]],
              include_blank: false,
              input_html: { class: 'chosen' }

      f.input :force_hit_rate

      f.input :reverse_billing,
              as: :select,
              collection: [['Yes', true], ['No', false]],
              include_blank: false,
              input_html: { class: 'chosen' }

      f.input :routing_tag_ids, as: :select, label: 'Routing Tags',
                                collection: routing_tag_options,
                                multiple: true,
                                include_hidden: false,
                                input_html: { class: 'chosen' }

      f.input :routing_tag_mode, as: :select,
                                 collection: Routing::RoutingTagMode.all,
                                 include_blank: false,
                                 input_html: { class: 'chosen' }
    end
    f.actions
  end
end
