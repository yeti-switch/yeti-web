FactoryGirl.define do
  factory :routeset_discriminator, class: Routing::RoutesetDiscriminator do
    sequence(:name) { |n| "Discriminator #{n}" }
  end
end
