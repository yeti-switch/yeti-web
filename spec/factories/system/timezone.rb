FactoryGirl.define do
  factory :timezone, class: System::Timezone do
    sequence(:name) { |n| "timezone#{n}"}
    abbrev "UTC"
    utc_offset "00:00:00"
    is_dst false
  end
end
