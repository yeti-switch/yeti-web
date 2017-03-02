shared_context :init_registration do |args|

  args ||= {}

  before do
    fields = {
        name: 'HOT-Free-Telecom-REG',
        enabled: false,
        pop_id: 3,
        node_id: 10,
        domain: '172.18.177.15',
        username: '773186999',
        display_username: '',
        auth_user: '773186999',
        contact: 'sip:773186999@10.9.0.82:5060',
        auth_password: 'a1SwnCYB',
        force_expire: false
    }.merge(args)

    @registration = FactoryGirl.create(:registration, fields)
  end

end