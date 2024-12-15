# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth_normalized
#
#  id                               :integer(4)       not null, primary key
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(2)
#  check_account_balance            :boolean          default(TRUE), not null
#  cps_limit                        :float
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dst_number_max_length            :integer(2)       default(100), not null
#  dst_number_min_length            :integer(2)       default(0), not null
#  dst_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_prefix                       :string           default(""), not null
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enable_audio_recording           :boolean          default(FALSE), not null
#  enabled                          :boolean          default(TRUE), not null
#  external_type                    :string
#  from_domain                      :string
#  interface                        :string
#  ip                               :inet             not null
#  name                             :string           not null
#  pai_rewrite_result               :string
#  pai_rewrite_rule                 :string
#  reject_calls                     :boolean          default(FALSE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_max_length            :integer(2)       default(100), not null
#  src_number_min_length            :integer(2)       default(0), not null
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_numberlist_use_diversion     :boolean          default(FALSE), not null
#  src_prefix                       :string           default(""), not null
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  ss_dst_rewrite_result            :string
#  ss_dst_rewrite_rule              :string
#  ss_src_rewrite_result            :string
#  ss_src_rewrite_rule              :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  to_domain                        :string
#  uri_domain                       :string
#  x_yeti_auth                      :string
#  account_id                       :integer(4)
#  cnam_database_id                 :integer(2)
#  customer_id                      :integer(4)       not null
#  customers_auth_id                :integer(4)       not null
#  diversion_policy_id              :integer(2)       default(1), not null
#  dst_number_field_id              :integer(2)       default(1), not null
#  dst_numberlist_id                :integer(2)
#  dump_level_id                    :integer(2)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_id                       :integer(4)       not null
#  lua_script_id                    :integer(2)
#  pai_policy_id                    :integer(2)       default(1), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(1), not null
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)       not null
#  rewrite_ss_status_id             :integer(2)
#  routing_plan_id                  :integer(4)       not null
#  src_name_field_id                :integer(2)       default(1), not null
#  src_number_field_id              :integer(2)       default(1), not null
#  src_numberlist_id                :integer(2)
#  ss_invalid_identity_action_id    :integer(2)       default(0), not null
#  ss_mode_id                       :integer(2)       default(0), not null
#  ss_no_identity_action_id         :integer(2)       default(0), not null
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#
# Indexes
#
#  customers_auth_normalized_customers_auth_id                  (customers_auth_id)
#  customers_auth_normalized_ip_prefix_range_prefix_range1_idx  (ip, ((dst_prefix)::prefix_range), ((src_prefix)::prefix_range)) USING gist
#  customers_auth_normalized_prefix_range_prefix_range1_idx     (((dst_prefix)::prefix_range), ((src_prefix)::prefix_range)) WHERE enabled USING gist
#
# Foreign Keys
#
#  customers_auth_normalized_customers_auth_id_fkey  (customers_auth_id => customers_auth.id)
#

class CustomersAuthNormalized < ApplicationRecord
  self.table_name = 'class4.customers_auth_normalized'

  belongs_to :customers_auth

  # attributes which are copyed "as is" without convertation
  def self.shadow_column_names
    skip_columns = %i[id customers_auth_id] +
                   CustomersAuth::CONST::MATCH_CONDITION_ATTRIBUTES
    column_names.map(&:to_sym) - skip_columns
  end

  # TODO: move all logic here
  def self.create_copies_from_original(customers_auth)
    # Transacton do
    #   each...
    # end
  end
end
