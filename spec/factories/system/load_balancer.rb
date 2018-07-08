FactoryGirl.define do
  factory :system_load_balancer, class: System::LoadBalancer do
    name 'TEST BALANCER'
    signalling_ip '1.2.3.4'
  end
end
