# frozen_string_literal: true

ActiveAdmin.register RealtimeData::SipOptionsProber, as: 'Sip Options Probers' do
  menu parent: 'Realtime Data', label: 'Sip Options Probers', priority: 10
  config.batch_actions = false
  config.filters = false

  actions :index

  decorate_with SipOptionsProberDecorator

  controller do
    def scoped_collection
      RealtimeData::SipOptionsProber.all
    end

    def apply_sorting(chain)
      chain
    end

    def apply_filtering(chain)
      query_params = (params.to_unsafe_h[:q] || {}).delete_if { |_, v| v.blank? }
      @search = OpenStruct.new(query_params)
      chain.where(query_params)
    end

    def apply_pagination(chain)
      @skip_drop_down_pagination = true
      records = chain.to_a
      Kaminari.paginate_array(records).page(1).per(records.size)
    end
  end

  index do
    column :id
    column :node, :node_link
    column 'SIP Options prober', :equipment_sip_options_prober_link
    column :append_headers
    column :contact
    column :from
    column :interval
    column :last_reply_code
    column :last_reply_contact
    column :last_reply_delay_ms
    column :last_reply_reason
    column :local_tag
    column :ruri
    column :route_set
    column :sip_interface_name
    column :to
  end
end
