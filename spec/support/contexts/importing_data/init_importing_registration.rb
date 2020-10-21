# frozen_string_literal: true

shared_context :init_importing_registration do |args|
  args ||= {}

  before do
    fields = {
      name: 'Com-REG',
      enabled: false,
      pop_name: @pop.name,
      pop_id: @pop.id,
      node_name: @node.name,
      node_id: @node.id,
      domain: '2.2.2.2',
      username: '87875678665657',
      display_username: '',
      auth_user: '5675765',
      contact: 'sip:576567576576@10.9.0.82:5060',
      auth_password: '6897878968',
      force_expire: false,
      retry_delay: 123,
      max_attempts: 123,
      transport_protocol_id: 1,
      proxy_transport_protocol_id: 1,
      sip_schema_id: 1,
      is_changed: true
    }.merge(args)

    @importing_registration = FactoryBot.create(:importing_registration, fields)
  end
end
