FactoryGirl.define do
  factory :numberlist, class: Routing::Numberlist do
    # sequence(:id, 10)
    sequence(:name) { |n| "numberlist#{n}"}

    after :build do |numberlist|
      numberlist.mode ||= Routing::NumberlistMode.create(name: 'mode')
      numberlist.default_action ||= Routing::NumberlistAction.create(name: 'action')
    end
  end
end
