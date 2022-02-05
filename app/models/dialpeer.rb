# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dialpeers
#
#  id                        :bigint(8)        not null, primary key
#  acd_limit                 :float            default(0.0), not null
#  asr_limit                 :float            default(0.0), not null
#  capacity                  :integer(2)
#  connect_fee               :decimal(, )      default(0.0), not null
#  dst_number_max_length     :integer(2)       default(100), not null
#  dst_number_min_length     :integer(2)       default(0), not null
#  dst_rewrite_result        :string
#  dst_rewrite_rule          :string
#  enabled                   :boolean          not null
#  exclusive_route           :boolean          default(FALSE), not null
#  force_hit_rate            :float
#  initial_interval          :integer(4)       default(1), not null
#  initial_rate              :decimal(, )      not null
#  lcr_rate_multiplier       :decimal(, )      default(1.0), not null
#  locked                    :boolean          default(FALSE), not null
#  next_interval             :integer(4)       default(1), not null
#  next_rate                 :decimal(, )      not null
#  prefix                    :string           not null
#  priority                  :integer(4)       default(100), not null
#  reverse_billing           :boolean          default(FALSE), not null
#  routing_tag_ids           :integer(2)       default([]), not null, is an Array
#  short_calls_limit         :float            default(1.0), not null
#  src_name_rewrite_result   :string
#  src_name_rewrite_rule     :string
#  src_rewrite_result        :string
#  src_rewrite_rule          :string
#  valid_from                :datetime         not null
#  valid_till                :datetime         not null
#  created_at                :datetime         not null
#  account_id                :integer(4)       not null
#  current_rate_id           :bigint(8)
#  external_id               :bigint(8)
#  gateway_group_id          :integer(4)
#  gateway_id                :integer(4)
#  network_prefix_id         :integer(4)
#  routeset_discriminator_id :integer(2)       default(1), not null
#  routing_group_id          :integer(4)       not null
#  routing_tag_mode_id       :integer(2)       default(0), not null
#  vendor_id                 :integer(4)       not null
#
# Indexes
#
#  dialpeers_external_id_idx                          (external_id)
#  dialpeers_prefix_range_idx                         (((prefix)::prefix_range)) USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx   (((prefix)::prefix_range), valid_from, valid_till) WHERE enabled USING gist
#  dialpeers_prefix_range_valid_from_valid_till_idx1  (((prefix)::prefix_range), valid_from, valid_till) WHERE (enabled AND (NOT locked)) USING gist
#
# Foreign Keys
#
#  dialpeers_account_id_fkey                 (account_id => accounts.id)
#  dialpeers_gateway_group_id_fkey           (gateway_group_id => gateway_groups.id)
#  dialpeers_gateway_id_fkey                 (gateway_id => gateways.id)
#  dialpeers_routeset_discriminator_id_fkey  (routeset_discriminator_id => routeset_discriminators.id)
#  dialpeers_routing_group_id_fkey           (routing_group_id => routing_groups.id)
#  dialpeers_routing_tag_mode_id_fkey        (routing_tag_mode_id => routing_tag_modes.id)
#  dialpeers_vendor_id_fkey                  (vendor_id => contractors.id)
#

class Dialpeer < ApplicationRecord
  self.table_name = 'class4.dialpeers'

  belongs_to :gateway, optional: true
  belongs_to :gateway_group, optional: true
  belongs_to :routing_group
  belongs_to :account
  belongs_to :vendor, class_name: 'Contractor'
  has_one :statistic, class_name: 'DialpeersStat', dependent: :delete
  include WithPaperTrail
  has_many :quality_stats, class_name: 'Stats::TerminationQualityStat', foreign_key: :dialpeer_id
  has_many :dialpeer_next_rates, class_name: 'DialpeerNextRate', foreign_key: :dialpeer_id, dependent: :delete_all
  belongs_to :current_rate, class_name: 'DialpeerNextRate', foreign_key: :current_rate_id, optional: true
  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id
  belongs_to :routeset_discriminator, class_name: 'Routing::RoutesetDiscriminator', foreign_key: :routeset_discriminator_id

  # has_many :routing_plans, class_name: 'Routing::RoutingPlan', foreign_key: :routing_group_id
  # has_and_belongs_to_many :routing_plans, class_name: 'Routing::RoutingPlan', join_table: "class4.routing_plan_groups", association_foreign_key: :routing_group_id
  array_belongs_to :routing_tags, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_ids

  validates :account, :routing_group, :vendor, :valid_from, :valid_till,
                        :initial_rate, :next_rate,
                        :initial_interval, :next_interval, :connect_fee,
                        :routing_tag_mode, :routeset_discriminator, :lcr_rate_multiplier, presence: true
  validates :initial_rate, :next_rate, :connect_fee, :lcr_rate_multiplier, numericality: true
  validates :initial_interval, :next_interval, numericality: { greater_than: 0 } # we have DB constraints for this
  validates :acd_limit, numericality: { greater_than_or_equal_to: 0.00 }
  validates :asr_limit, numericality: { greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00 }
  validates :short_calls_limit, numericality: { greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00 }

  validates :force_hit_rate, numericality: { greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00, allow_blank: true }
  validates :capacity, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  validates :dst_number_min_length, :dst_number_max_length, presence: true
  validates :dst_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :prefix, format: { without: /\s/ }
  validates :batch_prefix, format: { without: /\s/ }

  validate :contractor_is_vendor
  validate :vendor_owners_the_account, if: :account
  validate :gateway_presence
  validate :vendor_owners_the_gateway, if: :gateway
  validate :vendor_owners_the_gateway_group, if: :gateway_group

  validates_with RoutingTagIdsValidator

  attr_accessor :batch_prefix

  include Yeti::ResourceStatus
  include Yeti::NetworkDetector
  include RoutingTagIdsScopeable

  scope :locked, -> { where locked: true }

  after_initialize do
    if new_record?
      self.connect_fee ||= 0
      self.initial_interval ||= 1
      self.next_interval ||= 1
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

  def is_valid_from?
    valid_from < Time.now
  end

  def is_valid_till?
    valid_till > Time.now
  end

  def fire_lock(stat)
    transaction do
      self.locked = true
      save
      Notification::Alert.fire_lock(self, stat)
    end
  end

  def unlock
    transaction do
      self.locked = false
      save
      Notification::Alert.fire_unlock(self)
    end
  end

  scope :routing_for_contains, lambda { |prx|
    where('dialpeers.id in (
      select id from
      (
        SELECT t_dp.id as id,
        rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r
        FROM class4.dialpeers t_dp
        WHERE
          prefix_range(t_dp.prefix)@>prefix_range(?) and
          length(?)>=t_dp.dst_number_min_length and
          length(?)<=t_dp.dst_number_max_length
      ) h where h.r=1
    )', prx, prx, prx)
  }

  protected

  def gateway_presence
    errors.add(:base, 'Specify a gateway_group or a gateway') if gateway.blank? && gateway_group.blank?
  end

  def contractor_is_vendor
    errors.add(:vendor, 'Is not vendor') unless vendor&.vendor
  end

  def vendor_owners_the_account
    errors.add(:account, 'must be owned by selected vendor') unless account_id.nil? || (vendor_id && vendor_id == account.contractor_id)
  end

  def vendor_owners_the_gateway
    return true if gateway_id.nil? || gateway.is_shared?

    unless vendor_id && vendor_id == gateway.contractor_id
      errors.add(:gateway, 'must be owned by selected vendor or be shared')
    end

    unless gateway.allow_termination
      errors.add(:gateway, 'must be allowed for termination')
    end
  end

  def vendor_owners_the_gateway_group
    return true if gateway_group_id.nil? || gateway_group.is_shared?

    unless vendor_id && vendor_id == gateway_group.vendor_id
      errors.add(:gateway_group, 'must be owned by selected vendor or be shared')
    end
  end

  scope :routing_tag_ids_array_contains, ->(*tag_id) { where.contains routing_tag_ids: Array(tag_id) }

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      routing_tag_ids_array_contains
      routing_for_contains
      routing_tag_ids_covers
      tagged
      routing_tag_ids_count_equals
    ]
  end
end
