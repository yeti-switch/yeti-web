# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destinations
#
#  id                     :bigint(8)        not null, primary key
#  acd_limit              :float(24)        default(0.0), not null
#  allow_package_billing  :boolean          default(FALSE), not null
#  asr_limit              :float(24)        default(0.0), not null
#  connect_fee            :decimal(, )      default(0.0)
#  dp_margin_fixed        :decimal(, )      default(0.0), not null
#  dp_margin_percent      :decimal(, )      default(0.0), not null
#  dst_number_max_length  :integer(2)       default(100), not null
#  dst_number_min_length  :integer(2)       default(0), not null
#  enabled                :boolean          not null
#  initial_interval       :integer(4)       default(1), not null
#  initial_rate           :decimal(, )      not null
#  next_interval          :integer(4)       default(1), not null
#  next_rate              :decimal(, )      not null
#  prefix                 :string           not null
#  quality_alarm          :boolean          default(FALSE), not null
#  reject_calls           :boolean          default(FALSE), not null
#  reverse_billing        :boolean          default(FALSE), not null
#  routing_tag_ids        :integer(2)       default([]), not null, is an Array
#  short_calls_limit      :float(24)        default(0.0), not null
#  use_dp_intervals       :boolean          default(FALSE), not null
#  uuid                   :uuid             not null
#  valid_from             :timestamptz      not null
#  valid_till             :timestamptz      not null
#  external_id            :bigint(8)
#  network_prefix_id      :integer(4)
#  profit_control_mode_id :integer(2)
#  rate_group_id          :integer(4)       not null
#  rate_policy_id         :integer(4)       default(1), not null
#  routing_tag_mode_id    :integer(2)       default(0), not null
#
# Indexes
#
#  destinations_prefix_range_idx  (((prefix)::prefix_range)) USING gist
#  destinations_uuid_key          (uuid) UNIQUE
#
# Foreign Keys
#
#  destinations_rate_group_id_fkey        (rate_group_id => rate_groups.id)
#  destinations_routing_tag_mode_id_fkey  (routing_tag_mode_id => routing_tag_modes.id)
#

class Routing::Destination < ApplicationRecord
  self.table_name = 'class4.destinations'

  belongs_to :rate_group, class_name: 'Routing::RateGroup', foreign_key: :rate_group_id
  has_many :rateplans, class_name: 'Routing::Rateplan', through: :rate_group
  has_many :customers_auths, through: :rateplans

  has_many :quality_stats, class_name: 'Stats::TerminationQualityStat', foreign_key: :destination_id
  has_many :destination_next_rates, class_name: 'Routing::DestinationNextRate', foreign_key: :destination_id, dependent: :delete_all

  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id
  array_belongs_to :routing_tags, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_ids

  include WithPaperTrail

  include Yeti::ResourceStatus

  include Yeti::NetworkDetector

  include RoutingTagIdsScopeable

  scope :low_quality, -> { where quality_alarm: true }
  scope :time_valid, -> { where('valid_till >= :time AND valid_from < :time', time: Time.now) }
  scope :rateplan_id_filter, lambda { |value|
    rate_group_ids = Routing::RatePlanGroup.where(rateplan_id: value).pluck(:rate_group_id)
    where(rate_group_id: rate_group_ids)
  }
  scope :country_id_filter, lambda { |value|
    network_prefix_ids = System::NetworkPrefix.where(country_id: value).pluck(:id)
    where(network_prefix_id: network_prefix_ids)
  }
  scope :where_customer, lambda { |id|
    joins(:rate_group).joins(:rateplans).joins(:customers_auths).where(CustomersAuth.table_name => { customer_id: id })
  }

  scope :where_account, lambda { |id|
    joins(:rate_group).joins(:rateplans).joins(:customers_auths).where(CustomersAuth.table_name => { account_id: id })
  }

  validates :rate_group, :initial_rate, :next_rate, :initial_interval, :next_interval, :connect_fee,
                        :dp_margin_fixed, :dp_margin_percent, :rate_policy_id,
                        :asr_limit, :acd_limit, :short_calls_limit, :routing_tag_mode, presence: true
  validates :initial_rate, :next_rate, :initial_interval, :next_interval, :connect_fee, numericality: true
  validates :prefix, format: { without: /\s/ }

  validates :dst_number_min_length, :dst_number_max_length, presence: true
  validates :dst_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :profit_control_mode_id, inclusion: { in: Routing::RateProfitControlMode::MODES.keys }, allow_nil: true
  validates :rate_policy_id, inclusion: { in: Routing::DestinationRatePolicy::POLICIES.keys }, allow_nil: false

  validates_with RoutingTagIdsValidator

  #  validates_uniqueness_of :prefix, scope: [:rateplan_id]
  attr_accessor :batch_prefix

  after_initialize do
    if new_record?
      self.connect_fee ||= 0
      self.initial_interval ||= 1
      self.next_interval ||= 1
      self.dp_margin_fixed ||= 0
      self.dp_margin_percent ||= 1
      self.valid_from ||= DateTime.now
      self.valid_till ||= DateTime.now + 5.years
    end
  end

  before_create do
    if batch_prefix.present?
      prefixes = batch_prefix.delete(' ').split(',').uniq
      while prefixes.length > 1
        new_instance = dup
        new_instance.batch_prefix = nil
        new_instance.prefix = prefixes.pop
        new_instance.save!
      end
      self.prefix = prefixes.pop
      detect_network_prefix! # we need redetect network prefix. TODO: fix this shit
    else
      self.prefix = '' if prefix.nil?
      detect_network_prefix! # we need redetect network prefix. TODO: fix this shit
    end
  end

  def display_name
    "#{prefix} | #{id}"
  end

  def profit_control_mode_name
    Routing::RateProfitControlMode::MODES[profit_control_mode_id]
  end

  def rate_policy_name
    Routing::DestinationRatePolicy::POLICIES[rate_policy_id]
  end

  def is_valid_from?
    valid_from < Time.now
  end

  def is_valid_till?
    valid_till > Time.now
  end

  # TODO should be rewrited
  scope :routing_for_contains, lambda { |prx|
    where('destinations.id in (
      select id from
      (
        SELECT t_dst.id as id,
        rank() OVER (PARTITION BY t_dst.rate_group_id ORDER BY length(t_dst.prefix) desc) as r
        FROM class4.destinations t_dst
        WHERE prefix_range(t_dst.prefix)@>prefix_range(?) and
          length(?)>=t_dst.dst_number_min_length and
          length(?)<=t_dst.dst_number_max_length
      ) h where h.r=1
    )', prx, prx, prx)
  }

  scope :routing_tag_ids_array_contains, ->(*tag_id) { where.contains routing_tag_ids: Array(tag_id) }

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      routing_tag_ids_array_contains
      routing_for_contains
      routing_tag_ids_covers
      tagged
      routing_tag_ids_count_equals
      rateplan_id_filter
      country_id_filter
    ]
  end
end
