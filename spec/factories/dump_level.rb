FactoryGirl.define do
  factory :dump_level, class: DumpLevel do
    sequence(:name) { |n| "dump_level#{n}" }
    log_sip false
    log_rtp false
  end
end
