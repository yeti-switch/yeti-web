FactoryGirl.define do
  factory :timezone, class: System::Timezone do
    sequence(:name) { |n| "TZ#{n}"}
    sequence(:abbrev ) { |n| "TZ#{n}" }
    utc_offset 0
    is_dst false
  end
end
