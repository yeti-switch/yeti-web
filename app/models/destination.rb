# == Schema Information
#
# Table name: destinations
#
#  id                     :integer          not null, primary key
#  enabled                :boolean          not null
#  prefix                 :string           not null
#  rateplan_id            :integer          not null
#  next_rate              :decimal(, )      not null
#  connect_fee            :decimal(, )      default(0.0)
#  initial_interval       :integer          default(1), not null
#  next_interval          :integer          default(1), not null
#  dp_margin_fixed        :decimal(, )      default(0.0), not null
#  dp_margin_percent      :decimal(, )      default(0.0), not null
#  rate_policy_id         :integer          default(1), not null
#  initial_rate           :decimal(, )      not null
#  reject_calls           :boolean          default(FALSE), not null
#  use_dp_intervals       :boolean          default(FALSE), not null
#  valid_from             :datetime         not null
#  valid_till             :datetime         not null
#  profit_control_mode_id :integer
#  network_prefix_id      :integer
#  external_id            :integer
#  asr_limit              :float            default(0.0), not null
#  acd_limit              :float            default(0.0), not null
#  short_calls_limit      :float            default(0.0), not null
#  quality_alarm          :boolean          default(FALSE), not null
#  routing_tag_id         :integer
#

class Destination < ActiveRecord::Base
  belongs_to :rateplan
  belongs_to :rate_policy, class_name: 'DestinationRatePolicy', foreign_key: :rate_policy_id
  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode', foreign_key: :profit_control_mode_id
  belongs_to :routing_tag, class_name: Routing::RoutingTag, foreign_key: :routing_tag_id
  has_many :quality_stats, class_name: Stats::TerminationQualityStat, foreign_key: :destination_id, dependent: :nullify



  has_paper_trail class_name: 'AuditLogItem'

  include Yeti::ResourceStatus

  include Yeti::NetworkDetector

  scope :low_quality, -> { where quality_alarm: true }

  validates_presence_of :rateplan, :initial_rate, :next_rate, :initial_interval, :next_interval, :connect_fee,
                        :dp_margin_fixed, :dp_margin_percent, :rate_policy_id,
                        :asr_limit, :acd_limit, :short_calls_limit
  validates_numericality_of :initial_rate, :next_rate, :initial_interval, :next_interval, :connect_fee
  validates_format_of :prefix, without: /\s/

#  validates_uniqueness_of :prefix, scope: [:rateplan_id]
  attr_accessor :batch_prefix

  after_initialize do
    if self.new_record?
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


  def fire_alarm(stat)
    transaction do
      self.quality_alarm = true
      self.save
      Notification::Alert.fire_quality_alarm(self, stat)
    end
  end

  def clear_quality_alarm
    transaction do
      self.quality_alarm=false
      self.save
      Notification::Alert.clear_quality_alarm(self)
    end
  end

  def is_valid_from?
    valid_from < Time.now
  end

  def is_valid_till?
    valid_till > Time.now
  end
   
  scope :routing_for_contains, lambda {
                               #NEW logic, same as in routing procedures
  |prx| where('destinations.id in (
      select id from
      (
        SELECT t_dst.id as id,
        rank() OVER (PARTITION BY t_dst.rateplan_id ORDER BY length(t_dst.prefix) desc) as r
        FROM class4.destinations t_dst
        WHERE prefix_range(t_dst.prefix)@>prefix_range(?)
      ) h where h.r=1
    )', "#{prx}")
  }

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :routing_for_contains
    ]
  end

end
  
