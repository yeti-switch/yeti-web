# frozen_string_literal: true

ActiveAdmin.register RealtimeData::ActiveCall, as: 'Active Calls' do
  menu parent: 'Realtime Data', priority: 10, if: proc {
    authorized?(:index, RealtimeData::ActiveCall) && Node.any?
  }
  config.batch_actions = true
  batch_action :destroy, false

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

  filter :vendor_id_eq,
         as: :select,
         collection: proc { Contractor.vendors },
         label: 'Vendor',
         input_html: {
           class: 'chosen',
           onchange: remote_chosen_request(:get, with_contractor_accounts_path, { contractor_id: '$(this).val()' }, :q_vendor_acc_id_eq)
         },
         if: proc { !request.xhr? }

  filter :customer_id_eq,
         as: :select,
         collection: proc { Contractor.customers },
         label: 'Customer',
         input_html: {
           class: 'chosen',
           onchange: remote_chosen_request(:get, with_contractor_accounts_path, { contractor_id: '$(this).val()' }, :q_customer_acc_id_eq)
         },
         if: proc { !request.xhr? }

  filter :vendor_acc_id_eq,
         as: :select,
         collection: [],
         label: 'Vendor Account',
         input_html: { class: 'chosen' }

  filter :customer_acc_id_eq,
         as: :select,
         collection: [],
         label: 'Customer Account',
         input_html: { class: 'chosen' }

  filter :orig_gw_id_eq,
         as: :select,
         collection: proc { Gateway.originations },
         label: 'Orig GW',
         input_html: { class: 'chosen' },
         if: proc { !request.xhr? }

  filter :term_gw_id_eq,
         as: :select,
         collection: proc { Gateway.terminations },
         label: 'Term GW',
         input_html: { class: 'chosen' },
         if: proc { !request.xhr? }

  filter :duration, as: :numeric

  batch_action :terminate, confirm: 'Are you sure?', if: proc { authorized?(:batch_perform) } do |ids|
    authorize!
    ids.each do |node_id_with_local_tag|
      node_id, local_tag = node_id_with_local_tag.split('*')
      Node.find(node_id).drop_call(local_tag)
    rescue YetisNode::Error => e
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
  rescue YetisNode::Error => e
    flash[:notice] = "#{params[:id]} was terminated"
    redirect_to action: :index
  rescue StandardError => e
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
    def show
      show!
    rescue YetisNode::Error => e
      flash[:warning] = e.message
      redirect_to_back
    end

    def find_resource
      node_id, local_tag = params[:id].split('*')
      active_calls = [Node.find(node_id).active_call(local_tag)]
      active_calls = RealtimeData::ActiveCall.assign_foreign_resources(active_calls)
      active_calls.first
    end

    def find_collection(_options = {})
      @search = OpenStruct.new(params[:q])

      return [] if params[:q].blank? && GuiConfig.active_calls_require_filter

      active_calls = []
      begin
        is_list = active_admin_config.get_page_presenter(:index, params[:as]).options[:as] == :list_with_content # WTF?? .
        is_list = false #  dirty fix for https://bt.yeti-switch.org/issues/253
        only = is_list ? (RealtimeData::ActiveCall::LIST_ATTRIBUTES + RealtimeData::ActiveCall::SYSTEM_ATTRIBUTES) : nil # I don't understand what is only.
        active_calls = RealtimeData::ActiveCall.collection(Yeti::CdrsFilter.new(Node.all, params.to_unsafe_h[:q]).search(only: only, empty_on_error: true))
        active_calls = Kaminari.paginate_array(active_calls).page(1).per(active_calls.count)
        active_calls = RealtimeData::ActiveCall.assign_foreign_resources(active_calls)
      rescue StandardError => e
        flash.now[:warning] = e.message
        raise e
      end
      @skip_drop_down_pagination = true
      active_calls
    end
  end

  show do
    attributes_table do
      RealtimeData::ActiveCall.human_attributes.each do |attr|
        row attr
      end
    end
  end

  # collection_action :items_list do
  #   @active_calls = find_collection
  #   render "active_calls_collection", layout: false
  # end

  index do
    render 'active_calls_table', context: self
  end

  index as: :list_with_content, default: true, download_links: false, partial: 'shared/active_calls_top_chart',
        blank_slate_content: lambda {
          GuiConfig::FILTER_MISSED_TEXT if GuiConfig.active_calls_require_filter
        } do

    render 'active_calls_list', context: self
  end
end
