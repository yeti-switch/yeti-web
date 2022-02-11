# frozen_string_literal: true

ActiveAdmin.register RealtimeData::ActiveCall, as: 'Active Calls' do
  menu parent: 'Realtime Data', priority: 10, if: proc {
    authorized?(:index, RealtimeData::ActiveCall) && Node.any?
  }
  config.batch_actions = true
  batch_action :destroy, false
  decorate_with ActiveCallDecorator

  actions :index, :show

  filter :node_id_eq,
         as: :select,
         collection: proc { Node.all.pluck(:name, :id) },
         label: 'Node',
         input_html: { class: 'chosen' },
         if: proc {
           !request.xhr?
         }

  filter :dst_country_id_eq,
         as: :select,
         collection: proc { System::Country.all },
         label: 'Destination country',
         input_html: { class: 'chosen' },
         if: proc {
           !request.xhr?
         }

  filter :dst_network_id_eq,
         as: :select,
         collection: proc { System::Network.all },
         label: 'Destination network',
         input_html: { class: 'chosen' },
         if: proc { !request.xhr? }

  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }

  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true } }

  account_filter :vendor_acc_id_eq, label: 'Vendor Account',
                                    input_html: {
                                      class: 'vendor_id_eq-filter-child',
                                      'data-path-parents': { 'q[contractor_id_eq]': '.vendor_id_eq-filter' }.to_json,
                                      'data-path-required-parent': '.vendor_id_eq-filter'
                                    }

  account_filter :customer_acc_id_eq, label: 'Customer Account',
                                      input_html: {
                                        class: 'customer_id_eq-filter-child',
                                        'data-path-parents': { 'q[contractor_id_eq]': '.customer_id_eq-filter' }.to_json,
                                        'data-path-required-parent': '.customer_id_eq-filter'
                                      }

  filter :orig_gw_id_eq,
         as: :select,
         collection: proc {
           resource_id = params.fetch(:q, {})[:orig_gw_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         },
         label: 'Orig GW',
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search?q[allow_origination_eq]=true' }

  filter :term_gw_id_eq,
         as: :select,
         collection: proc {
           resource_id = params.fetch(:q, {})[:term_gw_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         },
         label: 'Term GW',
         input_html: {
           class: 'chosen-ajax',
           'data-path': '/gateways/search?q[allow_termination_eq]=true'
         }

  filter :duration, as: :numeric

  batch_action :terminate, confirm: 'Are you sure?', if: proc { authorized?(:batch_perform) } do |ids|
    authorize!(:batch_perform)
    ids.each do |node_id_with_local_tag|
      node_id, local_tag = node_id_with_local_tag.split('*')
      Node.find(node_id).drop_call(local_tag)
    rescue NodeApi::Error => e
      Rails.logger.warn { e.message }
    end
    flash[:notice] = 'Terminated!'
    redirect_to_back
  end

  member_action :drop, method: :post do
    node_id, local_tag = params[:id].split('*')
    Node.find(node_id).drop_call(local_tag)
    flash[:notice] = "#{params[:id]} was terminated"
    redirect_to action: :index
  rescue NodeApi::Error => e
    flash[:notice] = "#{params[:id]} was terminated"
    redirect_to action: :index
  rescue StandardError => e
    Rails.logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
    CaptureError.capture(e, tags: { component: 'AdminUI' }, extra: { params: params.to_unsafe_h })
    flash[:warning] = e.message
    redirect_to action: :index
  end

  action_item :drop, only: :show do
    link_to('Terminate', drop_active_call_path(id: resource.id), method: :post, data: { confirm: I18n.t('active_admin.delete_confirmation') })
  end

  before_action only: [:index] do
    params.delete(:q) if params[:q] && (params.to_unsafe_h[:q] || {}).delete_if { |_, v| v.blank? }.blank? && GuiConfig.active_calls_require_filter
  end

  controller do
    def index
      index!
    rescue StandardError => e
      flash.now[:warning] = e.message
      CaptureError.capture(e, tags: { component: 'AdminUI' })
      raise e
    end

    def show
      show!
    rescue NodeApi::Error => e
      flash[:warning] = e.message
      redirect_to_back
    end

    def scoped_collection
      # is_list = active_admin_config.get_page_presenter(:index, params[:as]).options[:as] == :list_with_content
      # # I don't understand what is only.
      # only = is_list ? (LIST_ATTRIBUTES + SYSTEM_ATTRIBUTES) : nil
      # only = nil #  dirty fix for https://bt.yeti-switch.org/issues/253
      # # Customer, Vendor, Duration, dst_prefix_routing, Start time, connect time,dst country,
      #   # Dst network, Destination next rate, Dialpeer next rate
      #   LIST_ATTRIBUTES = [
      #     :customer_id,
      #     :vendor_id,
      #     :duration,
      #     :dst_prefix_routing,
      #     :lrn,
      #     :start_time,
      #     :connect_time,
      #     # :dst_country_id,
      #     :dst_network_id,
      #     :destination_next_rate,
      #     :dialpeer_next_rate
      #   ].freeze
      #
      #   SYSTEM_ATTRIBUTES = %i[
      #     node_id
      #     local_tag
      #   ].freeze
      RealtimeData::ActiveCall.includes(*RealtimeData::ActiveCall.association_types.keys)
    end

    def apply_sorting(chain)
      chain
    end

    def apply_filtering(chain)
      query_params = (params.to_unsafe_h[:q] || {}).delete_if { |_, v| v.blank? }
      @search = OpenStruct.new(query_params)
      chain = chain.none if query_params.blank? && GuiConfig.active_calls_require_filter
      chain.where(query_params)
    end

    def apply_pagination(chain)
      @skip_drop_down_pagination = true
      records = chain.to_a
      Kaminari.paginate_array(records).page(1).per(records.size)
    end
  end

  show do
    attributes_table do
      row :start_time
      row :connect_time
      row :duration
      row :time_limit
      row :dst_prefix_in
      row :dst_prefix_routing
      row :lrn
      row :dst_prefix_out
      row :src_prefix_in
      row :src_prefix_routing
      row :src_prefix_out
      row :diversion_in
      row :diversion_out
      row :dst_country, &:dst_country_link
      row :dst_network, &:dst_network_link
      row :customer, &:customer_link
      row :vendor, &:vendor_link
      row :customer_acc, &:customer_acc_link
      row :vendor_acc, &:vendor_acc_link
      row :customer_auth, &:customer_auth_link
      row :destination, &:destination_link
      row :dialpeer, &:dialpeer_link
      row :orig_gw, &:orig_gw_link
      row :term_gw, &:term_gw_link
      row :routing_group, &:routing_group_link
      row :rateplan, &:rateplan_link
      row :destination_initial_rate
      row :destination_next_rate
      row :destination_initial_interval
      row :destination_next_interval
      row :destination_fee
      row :destination_rate_policy_id
      row :dialpeer_initial_rate
      row :dialpeer_next_rate
      row :dialpeer_initial_interval
      row :dialpeer_next_interval
      row :dialpeer_fee
      row :legA_remote_ip
      row :legA_remote_port
      row :orig_call_id
      row :legA_local_ip
      row :legA_local_port
      row :local_tag
      row :legB_local_ip
      row :legB_local_port
      row :term_call_id
      row :legB_remote_ip
      row :legB_remote_port
      row :node, &:node_link
      row :pop, &:pop_link
    end
    if resource._rest_attributes
      panel 'Extra Attributes' do
        attributes_table_for resource do
          resource._rest_attributes.each do |key, value|
            row(key) { value }
          end
        end
      end
    end
  end

  index blank_slate_content: lambda {
                               GuiConfig::FILTER_MISSED_TEXT if GuiConfig.active_calls_require_filter
                             } do
    selectable_column
    actions do |resource|
      item 'Terminate',
           url_for(action: :drop, id: resource.id),
           method: :post,
           class: 'member_link delete_link',
           data: { confirm: I18n.t('active_admin.delete_confirmation') }
    end
    column :start_time
    column :connect_time
    column :duration
    column :time_limit
    column :dst_prefix_in
    column :dst_prefix_routing
    column :lrn
    column :dst_prefix_out
    column :src_prefix_in
    column :src_prefix_routing
    column :src_prefix_out
    column :diversion_in
    column :diversion_out
    column :dst_country, :dst_country_link
    column :dst_network, :dst_network_link
    column :customer, :customer_link
    column :vendor, :vendor_link
    column :customer_acc, :customer_acc_link
    column :vendor_acc, :vendor_acc_link
    column :customer_auth, :customer_auth_link
    column :destination, :destination_link
    column :dialpeer, :dialpeer_link
    column :orig_gw, :orig_gw_link
    column :term_gw, :term_gw_link
    column :routing_group, :routing_group_link
    column :rateplan, :rateplan_link
    column :destination_initial_rate
    column :destination_next_rate
    column :destination_initial_interval
    column :destination_next_interval
    column :destination_fee
    column :destination_rate_policy_id
    column :dialpeer_initial_rate
    column :dialpeer_next_rate
    column :dialpeer_initial_interval
    column :dialpeer_next_interval
    column :dialpeer_fee
    column :legA_remote_ip
    column :legA_remote_port
    column :orig_call_id
    column :legA_local_ip
    column :legA_local_port
    column :local_tag
    column :legB_local_ip
    column :legB_local_port
    column :term_call_id
    column :legB_remote_ip
    column :legB_remote_port
    column :node, :node_link
    column :pop, :pop_link
  end
end
