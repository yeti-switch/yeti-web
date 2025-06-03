# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.traffic_sampling_rules
#
#  id                :integer(2)       not null, primary key
#  dst_prefix        :string           default(""), not null
#  dump_rate         :float            default(0.0), not null
#  recording_rate    :float            default(0.0), not null
#  src_prefix        :string           default(""), not null
#  customer_id       :integer(4)
#  customers_auth_id :integer(4)
#  dump_level_id     :integer(2)       default(0), not null
#
# Indexes
#
#  traffic_sampling_rules_customer_id_idx        (customer_id)
#  traffic_sampling_rules_customers_auth_id_idx  (customers_auth_id)
#
# Foreign Keys
#
#  traffic_sampling_rules_customer_id_fkey        (customer_id => contractors.id)
#  traffic_sampling_rules_customers_auth_id_fkey  (customers_auth_id => customers_auth.id)
#
class Routing::TrafficSamplingRule < ApplicationRecord
  self.table_name = 'class4.traffic_sampling_rules'

  include WithPaperTrail

  DUMP_LEVEL_DISABLED = 0
  DUMP_LEVEL_CAPTURE_SIP = 1
  DUMP_LEVEL_CAPTURE_RTP = 2
  DUMP_LEVEL_CAPTURE_ALL = 3
  DUMP_LEVELS = {
    DUMP_LEVEL_DISABLED => 'Capture nothing',
    DUMP_LEVEL_CAPTURE_SIP => 'Capture signaling traffic',
    DUMP_LEVEL_CAPTURE_RTP => 'Capture RTP traffic',
    DUMP_LEVEL_CAPTURE_ALL => 'Capture all traffic'
  }.freeze

  belongs_to :customers_auth, class_name: 'CustomersAuth', foreign_key: :customers_auth_id, optional: true
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true

  validates :dump_level_id,  presence: true, inclusion: { in: DUMP_LEVELS.keys }, allow_nil: false
  validates :dump_rate, :recording_rate, presence: true, allow_blank: false, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  def display_name
    "#{id}"
  end

  def dump_level_name
    dump_level_id.nil? ? DUMP_LEVELS[0] : DUMP_LEVELS[dump_level_id]
  end

end
