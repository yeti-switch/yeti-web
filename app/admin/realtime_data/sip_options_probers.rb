# frozen_string_literal: true

ActiveAdmin.register RealtimeData::SipOptionsProber, as: 'Sip Options Probers' do
  menu parent: 'Realtime Data', label: 'Sip Options Probers', priority: 10
  config.batch_actions = false

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

  filter :name, as: :string

  index do
    column :append_headers
    column :contact
    column :from
    column :id
    column :interval
    column :last_reply_code
    column :last_reply_contact
    column :last_reply_delay_ms
    column :last_reply_reason
    column :local_tag
    column :name
    column :proxy
    column :ruri
    column :sip_interface_name
    column :to

    column :transport_protocol, :transport_protocol_link
    column :proxy_transport_protocol, :proxy_transport_protocol_link
    column :node, :node_link
    column :pop, :pop_link
    column :sip_schema, :sip_schema_link
  end
end
