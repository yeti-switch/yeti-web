# frozen_string_literal: true

ActiveAdmin.register RealtimeData::SipOptionsProber, as: 'Sip Options Probers' do
  menu parent: 'Realtime Data', label: 'Sip Options Probers', priority: 10
  config.batch_actions = false
  config.sort_order = nil
  config.batch_actions = false
  config.paginate = false

  actions :index

  # decorate_with ActiveNodeDecorator

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
    column :node, :node_link
    column :pop, :pop_link
  end
end
