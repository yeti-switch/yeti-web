# == Schema Information
#
# Table name: customers_auth
#
#  id                               :integer          not null, primary key
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
#  dst_blacklist_id                 :integer
#  src_blacklist_id                 :integer
#  routing_plan_id                  :integer          not null
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  radius_auth_profile_id           :integer
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  enable_audio_recording           :boolean          default(FALSE), not null
#  radius_accounting_profile_id     :integer
#  enable_redirect                  :boolean          default(FALSE), not null
#  redirect_method                  :integer
#  redirect_to                      :string
#  from_domain                      :string
#  to_domain                        :string
#  transport_protocol_id            :integer
#

FactoryGirl.define do
  factory :customers_auth, class: CustomersAuth do
    customer_id nil
    rateplan_id nil
    enabled true
    ip nil
    account_id nil
    gateway_id nil
    src_rewrite_rule nil
    src_rewrite_result nil
    dst_rewrite_rule nil
    dst_rewrite_result nil
    src_prefix ''
    dst_prefix ''
    x_yeti_auth nil
    name nil
    dump_level_id 1
    capacity 0
    pop_id nil
    uri_domain nil
    src_name_rewrite_rule nil
    src_name_rewrite_result nil
    diversion_policy_id 1
    diversion_rewrite_rule nil
    diversion_rewrite_result nil
    dst_blacklist_id nil
    src_blacklist_id nil
    routing_group_id nil
    routing_plan_id nil
    allow_receive_rate_limit false
    send_billing_information false
  end
end
