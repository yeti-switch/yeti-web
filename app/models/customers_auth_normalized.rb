# == Schema Information
#
# Table name: class4.customers_auth_normalized
#
#  id                               :integer          not null, primary key
#  customers_auth_id                :integer          not null
#  customer_id                      :integer          not null
#  rateplan_id                      :integer          not null
#  enabled                          :boolean          default(TRUE), not null
#  ip                               :inet
#  account_id                       :integer
#  gateway_id                       :integer          not null
#  src_rewrite_rule                 :string
#  src_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dst_rewrite_result               :string
#  src_prefix                       :string           default(""), not null
#  dst_prefix                       :string           default(""), not null
#  x_yeti_auth                      :string
#  name                             :string           not null
#  dump_level_id                    :integer          default(0), not null
#  capacity                         :integer
#  pop_id                           :integer
#  uri_domain                       :string
#  src_name_rewrite_rule            :string
#  src_name_rewrite_result          :string
#  diversion_policy_id              :integer          default(1), not null
#  diversion_rewrite_rule           :string
#  diversion_rewrite_result         :string
#  dst_numberlist_id                :integer
#  src_numberlist_id                :integer
#  routing_plan_id                  :integer          not null
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  radius_auth_profile_id           :integer
#  enable_audio_recording           :boolean          default(FALSE), not null
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  radius_accounting_profile_id     :integer
#  from_domain                      :string
#  to_domain                        :string
#  transport_protocol_id            :integer
#  dst_number_min_length            :integer          default(0), not null
#  dst_number_max_length            :integer          default(100), not null
#  check_account_balance            :boolean          default(TRUE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  tag_action_id                    :integer
#  tag_action_value                 :integer          default([]), not null, is an Array
#  external_id                      :integer
#

class CustomersAuthNormalized < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth_normalized'

  belongs_to :customers_auth

  # attributes which are copyed "as is" without convertation
  def self.shadow_column_names
    skip_columns = [:id, :customers_auth_id] +
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
