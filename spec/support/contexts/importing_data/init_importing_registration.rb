shared_context :init_importing_registration do |args|

  args ||= {}

  before do
    fields = {
        name: 'HOT-Free-Telecom-REG',
        enabled: false,
        pop_name: 'ME',
        pop_id: 3,
        node_name: 'yeti-us-10',
        node_id: 10,
        domain: '172.18.177.15',
        username: '773186999',
        display_username: '',
        auth_user: '773186999',
        contact: 'sip:773186999@10.9.0.82:5060',
        auth_password: 'a1SwnCYB',
        force_expire: false,
        retry_delay: 123,
        max_attempts: 123,
        transport_protocol_id: 1,
        proxy_transport_protocol_id: 1
    }.merge(args)

    @importing_registration = FactoryGirl.create(:importing_registration, fields)
  end

end