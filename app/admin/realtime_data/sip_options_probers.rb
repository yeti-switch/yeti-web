# frozen_string_literal: true

ActiveAdmin.register RealtimeData::SipOptionsProber, as: 'Sip Options Probers' do
  menu parent: 'Realtime Data', label: 'Sip Options Probers', priority: 10
  config.batch_actions = false
  config.filters = false

  actions :index, :show

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
    column :id, :id_link
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
    column :name
    column :proxy
    column :ruri
    column :sip_interface_name
    column :to
  end

  show do
    attributes_table do
      row :id
      row :node, &:node_link
      row :append_headers
      row :contact
      row :from
      row :interval
      row :last_reply_code
      row :last_reply_contact
      row :last_reply_delay_ms
      row :last_reply_reason
      row :local_tag
      row :name
      row :proxy
      row :ruri
      row :sip_interface_name
      row :to
    end
  end
end
