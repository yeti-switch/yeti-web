ActiveAdmin.register CustomersAuth do


  menu parent: "Routing", priority: 10

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status

  decorate_with CustomersAuthDecorator

  acts_as_batch_changeable [:enabled, :uri_domain, :x_yeti_auth, :ip, :src_prefix, :dst_prefix]

  acts_as_export :id, :enabled, :name,
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) || "" }],
                 [:ip, proc {|row| row.raw_ip}],
                 [:pop_name, proc { |row| row.pop.try(:name) || "" }],
                 :src_prefix, :dst_prefix,
                 :uri_domain, :from_domain, :to_domain,
                 :x_yeti_auth,
                 [:customer_name, proc { |row| row.customer.try(:name) }],
                 [:account_name, proc { |row| row.account.try(:name) || "" }],
                 [:gateway_name, proc { |row| row.gateway.try(:name) || "" }],
                 [:rateplan_name, proc { |row| row.rateplan.try(:name) || "" }],
                 [:routing_plan_name, proc { |row| row.routing_plan.try(:name) || "" }],
                 [:dst_numberlist_name, proc { |row| row.dst_numberlist.try(:name) || "" }],
                 [:src_numberlist_name, proc { |row| row.src_numberlist.try(:name) || "" }],
                 [:dump_level_name, proc { |row| row.dump_level.try(:name) || "" }],
                 :enable_audio_recording,
                 :capacity,
                 :allow_receive_rate_limit,
                 :send_billing_information,
                 [:diversion_policy_name, proc { |row| row.diversion_policy.try(:name) || "" }],
                 :diversion_rewrite_rule, :diversion_rewrite_result,
                 :src_name_rewrite_rule, :src_name_rewrite_result,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 [:radius_auth_profile_name, proc { |row| row.radius_auth_profile.try(:name) || "" }],
                 :src_number_radius_rewrite_rule, :src_number_radius_rewrite_result,
                 :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
                 [:radius_accounting_profile_name, proc { |row| row.radius_accounting_profile.try(:name) || "" }]

  acts_as_import resource_class: Importing::CustomersAuth

  permit_params :name, :enabled, :customer_id, :rateplan_id, :routing_plan_id,
                :gateway_id, :account_id, :diversion_policy_id,
                :diversion_rewrite_rule, :diversion_rewrite_result,
                :src_name_rewrite_rule, :src_name_rewrite_result,
                :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule,
                :dst_rewrite_result,
                :dst_numberlist_id, :src_numberlist_id,
                :dump_level_id, :capacity, :allow_receive_rate_limit,
                :send_billing_information, :ip, :pop_id, :src_prefix,
                :dst_prefix, :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
                :radius_auth_profile_id,
                :src_number_radius_rewrite_rule, :src_number_radius_rewrite_result,
                :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
                :radius_accounting_profile_id,
                :enable_audio_recording,
                :transport_protocol_id
                #, :enable_redirect, :redirect_method, :redirect_to

  includes :rateplan, :routing_plan, :gateway, :dump_level, :src_numberlist, :dst_numberlist,
           :pop, :diversion_policy, :radius_auth_profile, :radius_accounting_profile, :customer, :transport_protocol, account: :contractor


  batch_action :change_dump_level, priority: 1, form: -> {
    {
        dump_level: DumpLevel.order(:name).pluck(:name, :id)
    }
  } do |ids, inputs|
    begin
      count = apply_authorization_scope(scoped_collection).where(id: ids).update_all(dump_level_id: inputs['dump_level'])
      flash[:notice] = "#{count}/#{ids.count} records updated ##{inputs['group']}"
    rescue StandardError => e
      flash[:error] = e.message
      Rails.logger.warn "UCS#batch_assign_to_group raise exception: #{e.message}\n#{e.backtrace.join("\n")}"
    end
    redirect_to :back
  end


  collection_action :search_for_debug do
    src_prefix=params[:src_prefix].to_s
    dst_prefix=params[:dst_prefix].to_s
    @ca = CustomersAuth.search_for_debug(src_prefix, dst_prefix)
    render text: view_context.options_from_collection_for_select(@ca, :id, :display_name_for_debug)
  end

  scope :with_radius
  scope :with_dump


  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :transport_protocol
    column :ip do |row|
      row.raw_ip
    end
    column :pop
    column :src_prefix
    column :dst_prefix
    column :uri_domain
    column :from_domain
    column :to_domain
    column 'X-Yeti-Auth', sortable: 'x_yeti_auth' do |auth|
      auth.x_yeti_auth
    end

    column :customer, sortable: 'contractors.name' do |row|
      auto_link(row.customer, row.customer.decorated_customer_display_name)
    end
    column :account, sortable: 'accounts.name' do |row|
      auto_link(row.account, row.account.decorated_customer_display_name)
    end

    column :gateway, sortable: 'gateways.name' do |row|
      auto_link(row.gateway, row.gateway.decorated_origination_display_name)
    end
    column :rateplan, sortable: 'rateplans.name'
    column :routing_plan, sortable: 'routing_plans.name' do |row|
      auto_link(row.routing_plan, row.routing_plan.decorated_display_name)
    end

    column :dst_numberlist
    column :src_numberlist

    column :dump_level
    column :enable_audio_recording
    column :capacity
    column :allow_receive_rate_limit
    column :send_billing_information

    column :diversion_policy
    column :diversion_rewrite_rule
    column :diversion_rewrite_result

    column :src_name_rewrite_rule
    column :src_name_rewrite_result

    column :src_rewrite_rule
    column :src_rewrite_result

    column :dst_rewrite_rule
    column :dst_rewrite_result

    column :radius_auth_profile, sortable: 'radius_auth_profiles.name'
    column :src_number_radius_rewrite_rule
    column :src_number_radius_rewrite_result
    column :dst_number_radius_rewrite_rule
    column :dst_number_radius_rewrite_result
    column :radius_accounting_profile, sortable: 'radius_accounting_profiles.name'
    # column :enable_redirect
    # column :redirect_method
    # column :redirect_to
  end

  filter :id
  filter :name
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :customer, input_html: {class: 'chosen'}
  filter :account, input_html: {class: 'chosen'}
  filter :gateway, input_html: {class: 'chosen'}
  filter :rateplan, input_html: {class: 'chosen'}
  filter :routing_plan, input_html: {class: 'chosen'}
  filter :dump_level, as: :select, collection: DumpLevel.select([:id, :name]).reorder(:id)
  filter :enable_audio_recording, as: :select, collection: [["Yes", true], ["No", false]]
  filter :transport_protocol
  filter :ip_covers, as: :string, input_html: {class: 'search_filter_string'}
  filter :pop, input_html: {class: 'chosen'}
  filter :src_prefix
  filter :dst_prefix
  filter :uri_domain
  filter :from_domain
  filter :to_domain
  filter :x_yeti_auth
#  filter :enable_redirect, as: :select, collection: [["Yes", true], ["No", false]]

  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab :general do
        f.inputs do
          f.input :name, hint: I18n.t('hints.routing.customers_auth.name')
          f.input :enabled
          f.input :customer, hint: I18n.t('hints.routing.customers_auth.customer'),
                  input_html: {
                      class: 'chosen',
                      onchange: remote_chosen_request(:get, with_contractor_accounts_path, {contractor_id: "$(this).val()"}, :customers_auth_account_id) +
                          remote_chosen_request(:get, with_contractor_gateways_path, {contractor_id: "$(this).val()"}, :customers_auth_gateway_id)
                  }
          f.input :account, collection: (f.object.customer.nil? ? [] : f.object.customer.accounts),
                  include_blank: true,
                  input_html: {class: 'chosen'},
                  hint: I18n.t('hints.routing.customers_auth.account')

          f.input :gateway, collection: (f.object.customer.nil? ? [] : f.object.customer.gateways),
                  include_blank: true,
                  input_html: {class: 'chosen'},
                  hint: I18n.t('hints.routing.customers_auth.gateway')


          # f.input :enable_redirect
          # f.input :redirect_method, as: :select,  collection: CustomersAuth::REDIRECT_METHODS
          # f.input :redirect_to

          f.input :rateplan, input_html: {class: 'chosen'}, hint: I18n.t('hints.routing.customers_auth.rateplan')
          f.input :routing_plan, input_html: {class: 'chosen'}, hint: I18n.t('hints.routing.customers_auth.routing_plan')


          f.input :dst_numberlist, input_html: {class: 'chosen'}, include_blank: "None", hint: I18n.t('hints.routing.customers_auth.dst_numberlist')
          f.input :src_numberlist, input_html: {class: 'chosen'}, include_blank: "None", hint: I18n.t('hints.routing.customers_auth.src_numberlist')
          f.input :dump_level, as: :select, include_blank: false, collection: DumpLevel.select([:id, :name]).reorder(:id),
                  hint: I18n.t('hints.routing.customers_auth.dump_level')
          f.input :enable_audio_recording
          f.input :capacity, hint: I18n.t('hints.routing.customers_auth.capacity')
          f.input :allow_receive_rate_limit
          f.input :send_billing_information
        end

        f.inputs "Match conditions" do
          f.input :transport_protocol, as: :select, include_blank: "Any", hint: I18n.t('hints.routing.customers_auth.transport_protocol')
          f.input :ip, hint: I18n.t('hints.routing.customers_auth.ip')
          f.input :pop, as: :select, include_blank: "Any", input_html: {class: 'chosen'}, hint: I18n.t('hints.routing.customers_auth.pop')
          f.input :src_prefix, hint: I18n.t('hints.routing.customers_auth.src_prefix')
          f.input :dst_prefix, hint: I18n.t('hints.routing.customers_auth.dst_prefix')
          f.input :uri_domain, hint: I18n.t('hints.routing.customers_auth.uri_domain')
          f.input :from_domain, hint: I18n.t('hints.routing.customers_auth.from_domain')
          f.input :to_domain, hint: I18n.t('hints.routing.customers_auth.to_domain')
          f.input :x_yeti_auth, label: 'X-Yeti-Auth', hint: I18n.t('hints.routing.customers_auth.x_yeti_auth')
        end
      end

      tab :number_translation do
        f.inputs do
          f.input :diversion_policy, as: :select, include_blank: false, hint: I18n.t('hints.routing.customers_auth.diversion_policy')
          f.input :diversion_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.diversion_rewrite_rule')
          f.input :diversion_rewrite_result, hint: I18n.t('hints.routing.customers_auth.diversion_rewrite_result')

          f.input :src_name_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.src_name_rewrite_rule')
          f.input :src_name_rewrite_result, hint: I18n.t('hints.routing.customers_auth.src_name_rewrite_result')

          f.input :src_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.src_rewrite_rule')
          f.input :src_rewrite_result, hint: I18n.t('hints.routing.customers_auth.src_rewrite_result')

          f.input :dst_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.dst_rewrite_rule')
          f.input :dst_rewrite_result, hint: I18n.t('hints.routing.customers_auth.dst_rewrite_result')
        end
      end

      tab :radius do
        f.inputs do
          f.input :radius_auth_profile, hint: I18n.t('hints.routing.customers_auth.radius_auth_profile')
          f.input :src_number_radius_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.src_number_radius_rewrite_rule')
          f.input :src_number_radius_rewrite_result, hint: I18n.t('hints.routing.customers_auth.src_number_radius_rewrite_result')
          f.input :dst_number_radius_rewrite_rule, hint: I18n.t('hints.routing.customers_auth.dst_number_radius_rewrite_rule')
          f.input :dst_number_radius_rewrite_result, hint: I18n.t('hints.routing.customers_auth.dst_number_radius_rewrite_result')
          f.input :radius_accounting_profile, hint: I18n.t('hints.routing.customers_auth.radius_accounting_profile')
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
          row :enabled
          row :customer
          row :account
          row :gateway

          # row :enable_redirect
          # row :redirect_method
          # row :redirect_to

          row :rateplan
          row :routing_plan do
            auto_link(s.routing_plan, s.routing_plan.decorated_display_name)
          end

          row :dst_numberlist
          row :src_numberlist

          row :dump_level
          row :enable_audio_recording
          row :capacity
          row :allow_receive_rate_limit
          row :send_billing_information

        end
        panel "Match conditions" do
          attributes_table_for s do
            row :transport_protocol
            row :ip do
              s.raw_ip
            end
            row :pop
            row :src_prefix
            row :dst_prefix
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

          row :src_name_rewrite_rule
          row :src_name_rewrite_result

          row :src_rewrite_rule
          row :src_rewrite_result
          row :dst_rewrite_rule
          row :dst_rewrite_result
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

    end


  end


end
