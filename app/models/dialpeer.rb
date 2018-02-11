# == Schema Information
#
# Table name: dialpeers
#
#  id                      :integer          not null, primary key
#  enabled                 :boolean          not null
#  prefix                  :string           not null
#  src_rewrite_rule        :string
#  dst_rewrite_rule        :string
#  acd_limit               :float            default("0"), not null
#  asr_limit               :float            default("0.0"), not null
#  gateway_id              :integer
#  routing_group_id        :integer          not null
#  next_rate               :decimal(, )      not null
#  connect_fee             :decimal(, )      default("0.0"), not null
#  vendor_id               :integer          not null
#  account_id              :integer          not null
#  src_rewrite_result      :string
#  dst_rewrite_result      :string
#  locked                  :boolean          default("false"), not null
#  priority                :integer          default("100"), not null
#  capacity                :integer
#  lcr_rate_multiplier     :decimal(, )      default("1"), not null
#  initial_rate            :decimal(, )      not null
#  initial_interval        :integer          default("1"), not null
#  next_interval           :integer          default("1"), not null
#  valid_from              :datetime         not null
#  valid_till              :datetime         not null
#  gateway_group_id        :integer
#  force_hit_rate          :float
#  network_prefix_id       :integer
#  created_at              :datetime         not null
#  short_calls_limit       :float            default("1"), not null
#  current_rate_id         :integer
#  external_id             :integer
#  src_name_rewrite_rule   :string
#  src_name_rewrite_result :string
#  exclusive_route         :boolean          default("false"), not null
#  routing_tag_id          :integer
#  dst_number_min_length   :integer          default("0"), not null
#  dst_number_max_length   :integer          default("100"), not null
#  reverse_billing         :boolean          default("false"), not null
#  routing_tag_ids         :integer          default("{}"), not null, is an Array
#

class Dialpeer < Yeti::ActiveRecord

  belongs_to :gateway
  belongs_to :gateway_group
  belongs_to :routing_group
  belongs_to :account
  belongs_to :vendor,  class_name: 'Contractor'
  belongs_to :routing_tag, class_name: Routing::RoutingTag, foreign_key: :routing_tag_id
  has_one :statistic, class_name: 'DialpeersStat', dependent: :delete
  has_paper_trail class_name: 'AuditLogItem'
  has_many :quality_stats, class_name: Stats::TerminationQualityStat, foreign_key: :dialpeer_id, dependent: :nullify
  has_many :dialpeer_next_rates, class_name: DialpeerNextRate, foreign_key: :dialpeer_id, dependent: :delete_all
  belongs_to :current_rate, class_name: DialpeerNextRate, foreign_key: :current_rate_id
 # has_many :routing_plans, class_name: Routing::RoutingPlan, foreign_key: :routing_group_id
  #has_and_belongs_to_many :routing_plans, class_name: Routing::RoutingPlan, join_table: "class4.routing_plan_groups", association_foreign_key: :routing_group_id


  validates_presence_of :account, :routing_group, :vendor, :valid_from, :valid_till, :initial_rate, :next_rate, :initial_interval, :next_interval, :connect_fee
  validates_numericality_of :initial_rate, :next_rate, :connect_fee
  validates_numericality_of :initial_interval, :next_interval, greater_than: 0 # we have DB constraints for this
  validates_numericality_of :acd_limit, greater_than_or_equal_to: 0.00
  validates_numericality_of :asr_limit, greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00
  validates_numericality_of :short_calls_limit, greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00

  validates_numericality_of :force_hit_rate, greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00, allow_blank: true
  validates_numericality_of :capacity, greater_than: 0, less_than: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  validates_presence_of :dst_number_min_length, :dst_number_max_length
  validates_numericality_of :dst_number_min_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true
  validates_numericality_of :dst_number_max_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true

  validates_format_of :prefix, without: /\s/
  validates_format_of :batch_prefix, without: /\s/

  validate :contractor_is_vendor
  validate :vendor_owners_the_account
  validate :gateway_presence
  validate :vendor_owners_the_gateway
  validate :vendor_owners_the_gateway_group

  validates_with RoutingTagIdsValidator

  attr_accessor :batch_prefix


  include Yeti::ResourceStatus
  include Yeti::NetworkDetector

  scope :locked, -> { where locked: true }

  after_initialize do
    if self.new_record?
      self.connect_fee ||= 0
      self.initial_interval ||= 1
      self.next_interval ||= 1
      self.valid_from ||= DateTime.now
      self.valid_till ||= DateTime.now + 5.years
    end
  end

  before_create do
    if batch_prefix.present?
      prefixes = batch_prefix.gsub(' ', '').split(',').uniq
      while prefixes.length > 1
        new_instance = self.dup
        new_instance.batch_prefix = nil
        new_instance.prefix = prefixes.pop
        new_instance.save!
      end
      self.prefix = prefixes.pop
      self.detect_network_prefix! # we need redetect network prefix. TODO: fix this shit
    else
      self.prefix = '' if self.prefix.nil?
      self.detect_network_prefix! # we need redetect network prefix. TODO: fix this shit
    end
  end

  def display_name
      "#{self.prefix} | #{self.id}"
  end

  def is_valid_from?
    valid_from < Time.now
  end

  def is_valid_till?
    valid_till > Time.now
  end

  def fire_lock(stat)
    transaction do
      self.locked=true
      self.save
      Notification::Alert.fire_lock(self, stat)
    end
  end

  def unlock
    transaction do
      self.locked=false
      self.save
      Notification::Alert.fire_unlock(self)
    end
  end

  scope :routing_for_contains, lambda {
          #NEW logic, same as in routing procedures
   # |prx| where('prefix_range(dialpeers.prefix)@>prefix_range(?)', "#{prx}")
   |prx| where('dialpeers.id in (
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
    errors.add(:base, "Specify a gateway_group or a gateway") if gateway.blank? && gateway_group.blank?
  end

  def contractor_is_vendor
     self.errors.add(:vendor, "Is not vendor") unless self.vendor && self.vendor.vendor
  end

  def vendor_owners_the_account
    self.errors.add(:account, "must be owned by selected vendor") unless self.account_id.nil? || (self.vendor_id && self.vendor_id == self.account.contractor_id)
  end

  def vendor_owners_the_gateway
    return true if self.gateway_id.nil? || self.gateway.is_shared?

    unless self.vendor_id && self.vendor_id == self.gateway.contractor_id
      self.errors.add(:gateway, "must be owned by selected vendor or be shared")
    end

    unless self.gateway.allow_termination
      self.errors.add(:gateway, 'must be allowed for termination')
    end
  end

  def vendor_owners_the_gateway_group
    self.errors.add(:gateway_group, "must be owned by selected vendor") unless self.gateway_group_id.nil? || (self.vendor_id && self.gateway_group_id && self.vendor_id == self.gateway_group.vendor_id)
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :routing_for_contains
    ]
  end

end
