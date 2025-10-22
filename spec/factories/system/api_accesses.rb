# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_access
#
#  id                                :integer(4)       not null, primary key
#  account_ids                       :integer(4)       default([]), not null, is an Array
#  allow_listen_recording            :boolean          default(FALSE), not null
#  allow_outgoing_numberlists_ids    :integer(4)       default([]), not null, is an Array
#  allowed_ips                       :inet             default(["\"0.0.0.0/0\"", "\"::/0\""]), not null, is an Array
#  login                             :string           not null
#  password_digest                   :string           not null
#  created_at                        :timestamptz
#  updated_at                        :timestamptz
#  customer_id                       :integer(4)       not null
#  customer_portal_access_profile_id :integer(2)       default(1), not null
#  provision_gateway_id              :integer(4)
#
# Indexes
#
#  api_access_customer_id_idx                             (customer_id)
#  api_access_login_key                                   (login) UNIQUE
#  api_access_provision_gateway_id_idx                    (provision_gateway_id)
#  index_api_access_on_customer_portal_access_profile_id  (customer_portal_access_profile_id)
#
# Foreign Keys
#
#  api_access_customer_id_fkey           (customer_id => contractors.id)
#  api_access_provision_gateway_id_fkey  (provision_gateway_id => gateways.id)
#  fk_rails_01e2f85455                   (customer_portal_access_profile_id => customer_portal_access_profiles.id)
#

FactoryBot.define do
  factory :api_access, class: 'System::ApiAccess' do
    sequence(:login) { |n| "api_access-#{n}" }
    password { ('a'..'z').to_a.shuffle.join }
    allowed_ips { ['0.0.0.0', '127.0.0.1'] }
    association :customer_portal_access_profile

    allow_outgoing_numberlists_ids { [] }

    customer
  end
end
