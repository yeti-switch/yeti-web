# frozen_string_literal: true

# == Schema Information
#
# Table name: import_dialpeers
#
#  id                          :bigint(8)        not null, primary key
#  account_name                :string
#  acd_limit                   :float
#  asr_limit                   :float
#  capacity                    :integer(4)
#  connect_fee                 :decimal(, )
#  dst_number_max_length       :integer(4)
#  dst_number_min_length       :integer(4)
#  dst_rewrite_result          :string
#  dst_rewrite_rule            :string
#  enabled                     :boolean
#  error_string                :string
#  exclusive_route             :boolean
#  force_hit_rate              :float
#  gateway_group_name          :string
#  gateway_name                :string
#  initial_interval            :integer(4)
#  initial_rate                :decimal(, )
#  is_changed                  :boolean
#  lcr_rate_multiplier         :decimal(, )
#  locked                      :boolean
#  next_interval               :integer(4)
#  next_rate                   :decimal(, )
#  prefix                      :string
#  priority                    :integer(4)
#  reverse_billing             :boolean
#  routeset_discriminator_name :string
#  routing_group_name          :string
#  routing_tag_ids             :integer(2)       default([]), not null, is an Array
#  routing_tag_mode_name       :string
#  routing_tag_names           :string
#  short_calls_limit           :float            default(1.0), not null
#  src_name_rewrite_result     :string
#  src_name_rewrite_rule       :string
#  src_rewrite_result          :string
#  src_rewrite_rule            :string
#  valid_from                  :datetime
#  valid_till                  :datetime
#  vendor_name                 :string
#  account_id                  :integer(4)
#  gateway_group_id            :integer(4)
#  gateway_id                  :integer(4)
#  o_id                        :bigint(8)
#  routeset_discriminator_id   :integer(2)
#  routing_group_id            :integer(4)
#  routing_tag_mode_id         :integer(2)
#  vendor_id                   :integer(4)
#

class Importing::Dialpeer < Importing::Base
  self.table_name = 'import_dialpeers'

  belongs_to :gateway, class_name: '::Gateway', optional: true
  belongs_to :gateway_group, class_name: '::GatewayGroup', optional: true
  belongs_to :routing_group, class_name: 'Routing::RoutingGroup', optional: true
  belongs_to :account, class_name: '::Account', optional: true
  belongs_to :vendor, -> { where vendor: true }, class_name: '::Contractor', optional: true
  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id, optional: true
  belongs_to :routeset_discriminator, class_name: 'Routing::RoutesetDiscriminator', foreign_key: :routeset_discriminator_id, optional: true
  has_many :dialpeer_next_rates, dependent: :destroy

  self.import_attributes = %w[prefix enabled lcr_rate_multiplier
                              initial_interval next_interval initial_rate next_rate connect_fee reverse_billing
                              gateway_id gateway_group_id routing_group_id
                              vendor_id account_id
                              src_name_rewrite_rule src_name_rewrite_result
                              src_rewrite_rule src_rewrite_result
                              dst_rewrite_rule dst_rewrite_result asr_limit acd_limit short_calls_limit priority capacity
                              valid_from valid_till force_hit_rate
                              dst_number_min_length dst_number_max_length
                              routing_tag_ids routing_tag_mode_id routeset_discriminator_id]
  import_for ::Dialpeer

  def self.after_import_hook
    where(asr_limit: nil).update_all(asr_limit: 0)
    resolve_array_of_tags('routing_tag_ids', 'routing_tag_names')
    resolve_null_tag('routing_tag_ids', 'routing_tag_names')
    super
  end
end
