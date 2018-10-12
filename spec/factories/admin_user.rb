FactoryGirl.define do
  factory :admin_user do
    username 'admin'
    sequence(:email) { |n| "admin#{n}@example.com" }
    password '111111'
    roles { ['user'] }
    after(:build) do |admin|
      if admin.class.ldap?
        admin.encrypted_password = admin.encrypt_password(admin.password)
      end
    end
  end

end
