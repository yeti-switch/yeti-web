# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_access
#
#  id              :integer(4)       not null, primary key
#  account_ids     :integer(4)       default([]), not null, is an Array
#  allowed_ips     :inet             default(["\"0.0.0.0/0\""]), not null, is an Array
#  login           :string           not null
#  password_digest :string           not null
#  customer_id     :integer(4)       not null
#
# Indexes
#
#  api_access_customer_id_idx  (customer_id)
#  api_access_login_key        (login) UNIQUE
#
# Foreign Keys
#
#  api_access_customer_id_fkey  (customer_id => contractors.id)

FactoryBot.define do
  factory :api_access, class: 'System::ApiAccess' do
    sequence(:login) { |n| "api_access-#{n}" }
    password { ('a'..'z').to_a.shuffle.join }
    allowed_ips { ['0.0.0.0', '127.0.0.1'] }

    customer
  end
end
