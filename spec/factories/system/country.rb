# frozen_string_literal: true

FactoryGirl.define do
  factory :country, class: System::Country do
    name 'United States'
    iso2 'US'
  end
end
