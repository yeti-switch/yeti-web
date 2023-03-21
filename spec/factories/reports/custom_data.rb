# frozen_string_literal: true

FactoryBot.define do
  factory :custom_data, class: Report::CustomData do
    report { association :interval_cdr }
  end
end
