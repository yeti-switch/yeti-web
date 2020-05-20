# frozen_string_literal: true

FactoryBot.define do
  factory :importing_disconnect_policy, class: Importing::DisconnectPolicy do
    o_id { nil }
    name { nil }
    error_string { nil }
  end
end
