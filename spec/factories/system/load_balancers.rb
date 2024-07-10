# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.load_balancers
#
#  id            :integer(2)       not null, primary key
#  name          :string           not null
#  signalling_ip :string           not null
#
# Indexes
#
#  load_balancers_name_key           (name) UNIQUE
#  load_balancers_signalling_ip_key  (signalling_ip) UNIQUE
#
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
