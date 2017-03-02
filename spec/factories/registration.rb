FactoryGirl.define do
  factory :registration, class: Equipment::Registration do
    name nil
    enabled true
    pop_id nil
    node_id nil
    domain nil
    username nil
    display_username nil
    auth_user nil
    proxy nil
    contact nil
    auth_password nil
    expire nil
    force_expire false
  end
end
