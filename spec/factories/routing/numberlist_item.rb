FactoryGirl.define do
  factory :numberlist_item, class: Routing::NumberlistItem do
    sequence(:key) { |n| "numberlist_item_#{n}"}

    association :numberlist
  end
end
