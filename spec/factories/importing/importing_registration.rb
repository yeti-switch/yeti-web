# frozen_string_literal: true

FactoryGirl.define do
  factory :importing_registration, class: Importing::Registration do
    o_id nil
    name nil
    enabled true
    pop_name nil
    pop_id nil
    node_name nil
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
    error_string nil
  end
end
