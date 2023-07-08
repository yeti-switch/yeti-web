# frozen_string_literal: true

ActiveAdmin.register CustomersAuth do
  menu parent: 'Routing', priority: 10

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  acts_as_async_destroy('CustomersAuth')
  acts_as_async_update BatchUpdateForm::CustomersAuth

  acts_as_delayed_job_lock

  decorate_with CustomersAuthDecorator

  acts_as_export :id, :enabled, :reject_calls, :name,
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) || '' }],
                 :ip,
                 [:pop_name, proc { |row| row.pop.try(:name) || '' }],
                 :src_prefix,
                 :src_number_min_length, :src_number_max_length,
                 :dst_prefix,
                 :dst_number_min_length, :dst_number_max_length,
                 :uri_domain, :from_domain, :to_domain,
                 :x_yeti_auth,
                 [:customer_name, proc { |row| row.customer.try(:name) }],
                 [:account_name, proc { |row| row.account.try(:name) || '' }],
                 :check_account_balance,
                 [:gateway_name, proc { |row| row.gateway.try(:name) || '' }],
                 :require_incoming_auth,
                 [:rateplan_name, proc { |row| row.rateplan.try(:name) || '' }],
                 [:routing_plan_name, proc { |row| row.routing_plan.try(:name) || '' }],
                 [:dst_numberlist_name, proc { |row| row.dst_numberlist.try(:name) || '' }],
                 [:src_numberlist_name, proc { |row| row.src_numberlist.try(:name) || '' }],
                 :dump_level_name,
                 :enable_audio_recording,
                 :capacity,
                 :cps_limit,
                 :allow_receive_rate_limit,
                 :send_billing_information,
                 [:diversion_policy_name, proc { |row| row.diversion_policy.try(:name) || '' }],
                 :diversion_rewrite_rule, :diversion_rewrite_result,
                 [:src_number_field_name, proc { |row| row.src_number_field.try(:name) }],
                 [:src_name_field_name, proc { |row| row.src_name_field.try(:name) }],
                 [:dst_number_field_name, proc { |row| row.dst_number_field.try(:name) }],
                 :src_name_rewrite_rule, :src_name_rewrite_result,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 [:cnam_database_name, proc { |row| row.cnam_database.try(:name) }],
                 [:lua_script_name, proc { |row| row.lua_script.try(:name) }],
                 [:radius_auth_profile_name, proc { |row| row.radius_auth_profile.try(:name) || '' }],
                 :src_number_radius_rewrite_rule, :src_number_radius_rewrite_result,
                 :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
                 [:radius_accounting_profile_name, proc { |row| row.radius_accounting_profile.try(:name) || '' }],
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) || '' }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }],
                 :rewrite_ss_status_name

  acts_as_import resource_class: Importing::CustomersAuth,
                 skip_columns: [:tag_action_value]

  permit_params :name, :enabled, :reject_calls, :customer_id, :rateplan_id, :routing_plan_id,
                :gateway_id, :require_incoming_auth, :account_id, :check_account_balance, :diversion_policy_id,
                :diversion_rewrite_rule, :diversion_rewrite_result,
                :src_name_rewrite_rule, :src_name_rewrite_result,
                :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule,
                :dst_rewrite_result,
                :dst_numberlist_id, :src_numberlist_id,
                :dump_level_id, :capacity, :cps_limit, :allow_receive_rate_limit,
                :send_billing_information,
                :ip, :pop_id,
                :src_prefix, :src_number_min_length, :src_number_max_length,
                :dst_prefix, :dst_number_min_length, :dst_number_max_length,
                :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
                :radius_auth_profile_id,
                :src_number_radius_rewrite_rule, :src_number_radius_rewrite_result,
                :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
                :radius_accounting_profile_id,
                :enable_audio_recording,
                :transport_protocol_id,
                :tag_action_id, :lua_script_id,
                :dst_number_field_id, :src_number_field_id, :src_name_field_id,
                :cnam_database_id, :src_numberlist_use_diversion, :rewrite_ss_status_id,
                tag_action_value: []
  # , :enable_redirect, :redirect_method, :redirect_to

  includes :tag_action, :rateplan, :routing_plan, :gateway, :src_numberlist, :dst_numberlist,
           :pop, :diversion_policy, :radius_auth_profile, :radius_accounting_profile, :customer, :transport_protocol,
           :lua_script, :src_name_field, :src_number_field, :dst_number_field, :cnam_database,
           account: :contractor

  controller do
    def update
      if params['customers_auth']['tag_action_value'].nil?
        params['customers_auth']['tag_action_value'] = []
      end
      super
    end
  end

  scope :with_radius
  scope :with_dump

  sidebar :normalized_copies, only: :show do
    ul do
      li "#{resource.normalized_copies.count} copies"
    end
    link_to 'View copies', customers_auth_normalized_copies_path(resource)
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :reject_calls
    column :transport_protocol
    column :ip
    column :external_id
    column :external_type
    column :pop
    column :src_prefix
    column :src_number_length do |c|
      c.src_number_min_length == c.src_number_max_length ? c.src_number_min_length.to_s : "#{c.src_number_min_length}..#{c.src_number_max_length}"
    end
    column :dst_prefix
    column :dst_number_length do |c|
      c.dst_number_min_length == c.dst_number_max_length ? c.dst_number_min_length.to_s : "#{c.dst_number_min_length}..#{c.dst_number_max_length}"
    end
    column :uri_domain
    column :from_domain
    column :to_domain
    column :x_yeti_auth

    column :customer, sortable: 'contractors.name' do |row|
      auto_link(row.customer, row.customer.decorated_customer_display_name)
    end
    column :account, sortable: 'accounts.name' do |row|
      auto_link(row.account, row.account.decorated_customer_display_name)
    end
    column :check_account_balance

    column :gateway, sortable: 'gateways.name' do |row|
      auto_link(row.gateway, row.gateway.decorated_origination_display_name)
    end
    column :require_incoming_auth

    column :rateplan, sortable: 'rateplans.name'
    column :routing_plan, sortable: 'routing_plans.name' do |row|
      auto_link(row.routing_plan, row.routing_plan.decorated_display_name)
    end

    column :dst_numberlist
    column :src_numberlist

    column :dump_level, &:dump_level_name
    column :enable_audio_recording
    column :capacity
    column :cps_limit
    column :allow_receive_rate_limit
    column :send_billing_information

    column :diversion_policy
    column :diversion_rewrite_rule
    column :diversion_rewrite_result

    column :src_name_field
    column :src_name_rewrite_rule
    column :src_name_rewrite_result

    column :src_number_field
    column :src_rewrite_rule
    column :src_rewrite_result

    column :dst_number_field
    column :dst_rewrite_rule
    column :dst_rewrite_result

    column :lua_script
    column :cnam_database

    column :radius_auth_profile, sortable: 'radius_auth_profiles.name'
    column :src_number_radius_rewrite_rule
    column :src_number_radius_rewrite_result
    column :dst_number_radius_rewrite_rule
    column :dst_number_radius_rewrite_result
    column :radius_accounting_profile, sortable: 'radius_accounting_profiles.name'

    column :tag_action
    column :display_tag_action_value
  end

  filter :id
  filter :external_id, label: 'External ID'
  filter :external_type
  filter :name
  filter :enabled, as: :select, collection: [['Yes', true], ['No', false]]
  filter :reject_calls, as: :select, collection: [['Yes', true], ['No', false]]

  contractor_filter :customer_id_eq,
                    label: 'Customer',
                    path_params: { q: { customer_eq: true } }

  account_filter :account_id_eq

  association_ajax_filter :gateway_id_eq,
                         label: 'Gateway',
                         scope: -> { Gateway.order(:name) },
                         path: '/gateways/search'

  filter :rateplan, input_html: { class: 'chosen' }
  filter :routing_plan, input_html: { class: 'chosen' }
  filter :dump_level_id_eq, label: 'Dump Level', as: :select, collection: CustomersAuth::DUMP_LEVELS.invert
  filter :enable_audio_recording, as: :select, collection: [['Yes', true], ['No', false]]
  filter :transport_protocol
  filter :ip_covers,
         as: :string,
         input_html: { class: 'search_filter_string' },
         label: I18n.t('activerecord.attributes.customers_auth.ip')
  filter :pop, input_html: { class: 'chosen' }
  filter :src_prefix_array_contains, label: I18n.t('activerecord.attributes.customers_auth.src_prefix')
  filter :dst_prefix_array_contains, label: I18n.t('activerecord.attributes.customers_auth.dst_prefix')
  filter :uri_domain_array_contains, label: I18n.t('activerecord.attributes.customers_auth.uri_domain')
  filter :from_domain_array_contains, label: I18n.t('activerecord.attributes.customers_auth.from_domain')
  filter :to_domain_array_contains, label: I18n.t('activerecord.attributes.customers_auth.to_domain')
  filter :x_yeti_auth_array_contains, label: I18n.t('activerecord.attributes.customers_auth.x_yeti_auth')
  filter :lua_script, input_html: { class: 'chosen' }
  boolean_filter :require_incoming_auth
  boolean_filter :check_account_balance
  filter :gateway_incoming_auth_username,
         label: 'Incoming Auth Username',
         as: :string
  filter :gateway_incoming_auth_password,
         label: 'Incoming Auth Password',
         as: :string
  filter :cnam_database, input_html: { class: 'chosen' }

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    tabs do
      tab :general do
        f.inputs do
          f.input :name
          f.input :enabled
          f.input :reject_calls
          f.contractor_input :customer_id,
                             label: 'Customer',
                             path_params: { q: { customer_eq: true } }

          f.account_input :account_id,
                          fill_params: { contractor_id_eq: f.object.customer_id },
                          input_html: {
                            'data-path-params': { 'q[contractor_id_eq]': '.customer_id-input' }.to_json,
                            'data-required-param': 'q[contractor_id_eq]'
                          }

          f.input :check_account_balance

          f.association_ajax_input :gateway_id,
                                   label: 'Gateway',
                                   scope: Gateway.order(:name),
                                   path: '/gateways/search',
                                   fill_params: { origination_contractor_id_eq: f.object.customer_id },
                                   input_html: {
                                     'data-path-params': { 'q[origination_contractor_id_eq]': '.customer_id-input' }.to_json,
                                     'data-required-param': 'q[origination_contractor_id_eq]'
                                   }

          f.input :require_incoming_auth

          f.input :rateplan, input_html: { class: 'chosen' }
          f.input :routing_plan, input_html: { class: 'chosen' }

          f.input :dst_numberlist, input_html: { class: 'chosen' }, include_blank: 'None'
          f.input :src_numberlist, input_html: { class: 'chosen' }, include_blank: 'None'
          f.input :dump_level_id, as: :select, include_blank: false, collection: CustomersAuth::DUMP_LEVELS.invert
          f.input :enable_audio_recording
          f.input :capacity
          f.input :cps_limit
          f.input :allow_receive_rate_limit
          f.input :send_billing_information
        end

        f.inputs 'Match conditions' do
          f.input :transport_protocol, as: :select, include_blank: 'Any'
          f.input :ip, as: :array_of_strings
          f.input :pop, as: :select, include_blank: 'Any', input_html: { class: 'chosen' }
          f.input :src_prefix, as: :array_of_strings
          f.input :src_number_min_length
          f.input :src_number_max_length
          f.input :dst_prefix, as: :array_of_strings
          f.input :dst_number_min_length
          f.input :dst_number_max_length
          f.input :uri_domain, as: :array_of_strings
          f.input :from_domain, as: :array_of_strings
          f.input :to_domain, as: :array_of_strings
          f.input :x_yeti_auth, as: :array_of_strings
        end
      end

      tab :number_translation do
        f.inputs do
          f.input :diversion_policy, as: :select, include_blank: false
          f.input :diversion_rewrite_rule
          f.input :diversion_rewrite_result
          f.input :src_numberlist_use_diversion

          f.input :src_name_field
          f.input :src_name_rewrite_rule
          f.input :src_name_rewrite_result

          f.input :src_number_field
          f.input :src_rewrite_rule
          f.input :src_rewrite_result

          f.input :dst_number_field
          f.input :dst_rewrite_rule
          f.input :dst_rewrite_result
          f.input :lua_script, input_html: { class: 'chosen' }, include_blank: 'None'
          f.input :cnam_database, input_html: { class: 'chosen' }, include_blank: 'None'
        end
      end

      tab :radius do
        f.inputs do
          f.input :radius_auth_profile, input_html: { class: 'chosen' }, include_blank: 'None'
          f.input :src_number_radius_rewrite_rule
          f.input :src_number_radius_rewrite_result
          f.input :dst_number_radius_rewrite_rule
          f.input :dst_number_radius_rewrite_result
          f.input :radius_accounting_profile, input_html: { class: 'chosen' }, include_blank: 'None'
        end
      end

      tab :routing_tags do
        f.inputs do
          f.input :tag_action
          f.input :tag_action_value, as: :select,
                                     collection: tag_action_value_options,
                                     multiple: true,
                                     include_hidden: false,
                                     input_html: { class: 'chosen' }
        end
      end

      tab :stir_shaken do
        f.inputs do
          f.input :rewrite_ss_status_id, as: :select, include_blank: true, collection: CustomersAuth::SS_STATUSES.invert
        end
      end
    end
    f.actions
  end

  show do |s|
    tabs do
      tab :general do
        attributes_table do
          row :name
          row :external_id
          row :external_type
          row :enabled
          row :reject_calls
          row :customer
          row :account
          row :check_account_balance
          row :gateway
          row :require_incoming_auth

          # row :enable_redirect
          # row :redirect_method
          # row :redirect_to

          row :rateplan
          row :routing_plan do
            auto_link(s.routing_plan, s.routing_plan.decorated_display_name)
          end

          row :dst_numberlist
          row :src_numberlist

          row :dump_level, &:dump_level_name
          row :enable_audio_recording
          row :capacity
          row :cps_limit
          row :allow_receive_rate_limit
          row :send_billing_information
        end
        panel 'Match conditions' do
          attributes_table_for s do
            row :transport_protocol
            row :ip
            row :pop
            row :src_prefix
            row :src_number_min_length
            row :src_number_max_length
            row :dst_prefix
            row :dst_number_min_length
            row :dst_number_max_length
            row :uri_domain
            row :from_domain
            row :to_domain
            row :x_yeti_auth
          end
        end
      end
      tab :number_translation do
        attributes_table do
          row :diversion_policy
          row :diversion_rewrite_rule
          row :diversion_rewrite_result
          row :src_numberlist_use_diversion

          row :src_name_field
          row :src_name_rewrite_rule
          row :src_name_rewrite_result

          row :src_number_field
          row :src_rewrite_rule
          row :src_rewrite_result

          row :dst_number_field
          row :dst_rewrite_rule
          row :dst_rewrite_result

          row :cnam_database
          row :lua_script
        end
      end
      tab :radius do
        attributes_table do
          row :radius_auth_profile
          row :src_number_radius_rewrite_rule
          row :src_number_radius_rewrite_result
          row :dst_number_radius_rewrite_rule
          row :dst_number_radius_rewrite_result
          row :radius_accounting_profile
        end
      end

      tab :routing_tags do
        attributes_table do
          row :tag_action
          row :display_tag_action_value
        end
      end

      tab :stir_shaken do
        attributes_table do
          row :rewrite_ss_status, &:rewrite_ss_status_name
        end
      end
    end
  end
end
