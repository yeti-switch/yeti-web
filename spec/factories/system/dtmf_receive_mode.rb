FactoryGirl.define do
  factory :dtmf_receive_mode, class: System::DtmfReceiveMode do
    sequence(:name) { |n| "mode#{n}"}
  end
end
