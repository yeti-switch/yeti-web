FactoryGirl.define do
  factory :dtmf_send_mode, class: System::DtmfSendMode do
    sequence(:name) { |n| "mode#{n}"}
  end
end
