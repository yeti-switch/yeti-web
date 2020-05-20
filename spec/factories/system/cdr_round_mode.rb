# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.call_duration_round_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryBot.define do
  factory :cdr_round_mode, class: System::CdrRoundMode do
    id { 3 }
    # sequence(:id) { |n| n }
    sequence(:name) { |n| "Always UP #{n}" }

    trait :always_up do
      id { 3 }
      name { 'Always UP' }
    end

    trait :always_down do
      id { 2 }
      name { 'Always DOWN' }
    end

    trait :if_0_5 do
      id { 1 }
      name { 'Math rules(up if >=0.5)' }
    end
  end
end
