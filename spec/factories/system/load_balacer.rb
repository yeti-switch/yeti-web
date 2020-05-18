# frozen_string_literal: true

FactoryBot.define do
  factory :system_load_balancer, class: System::LoadBalancer do
    name { 'TEST BALANCER' }
    signalling_ip { '1.2.3.4' }

    trait :uniq do
      sequence(:name) { |n| "TEST BALANCER_#{n}" }
      sequence(:signalling_ip) { |n| "1.2.3.#{n}" }
    end
  end
end
