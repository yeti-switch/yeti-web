# frozen_string_literal: true

# == Schema Information
#
# Table name: import_disconnect_policies
#
#  id           :bigint(8)        not null, primary key
#  error_string :string
#  is_changed   :boolean
#  name         :string
#  o_id         :integer(4)
#
FactoryBot.define do
  factory :importing_disconnect_policy, class: Importing::DisconnectPolicy do
    o_id { nil }
    name { nil }
    error_string { nil }
  end
end
