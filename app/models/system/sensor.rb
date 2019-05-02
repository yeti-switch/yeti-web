# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sensors
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  mode_id          :integer          not null
#  source_interface :string
#  target_mac       :macaddr
#  use_routing      :boolean          not null
#  target_ip        :inet
#  source_ip        :inet
#  target_port      :integer
#  hep_capture_id   :integer
#

class System::Sensor < Yeti::ActiveRecord
  self.table_name = 'sys.sensors'

  has_paper_trail class_name: 'AuditLogItem'
  belongs_to :mode, class_name: 'System::SensorMode', foreign_key: :mode_id

  has_many :gateways, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :mode, presence: true

  validates :source_ip,
            presence: { if: proc { |sensor| sensor.mode_id.to_i == System::SensorMode::IP_IP } },
            format: { with: /\A\z|\A((0|1[0-9]{0,2}|2[0-9]{0,1}|2[0-4][0-9]|25[0-5]|[3-9][0-9]{0,1})\.){3}(0|1[0-9]{0,2}|2[0-9]{0,1}|2[0-4][0-9]|25[0-5]|[3-9][0-9]{0,1})\z/ }

  validates :target_ip,
            presence: { if: proc { |sensor| (sensor.mode_id.to_i == System::SensorMode::IP_IP) || (sensor.mode_id.to_i == System::SensorMode::HEPv3) } },
            format: { with: /\A\z|\A((0|1[0-9]{0,2}|2[0-9]{0,1}|2[0-4][0-9]|25[0-5]|[3-9][0-9]{0,1})\.){3}(0|1[0-9]{0,2}|2[0-9]{0,1}|2[0-4][0-9]|25[0-5]|[3-9][0-9]{0,1})\z/ }

  validates :source_interface,
            presence: { if: proc { |sensor| sensor.mode_id.to_i == System::SensorMode::IP_ETHERNET } }

  validates :target_mac,
            presence: { if: proc { |sensor| sensor.mode_id.to_i == System::SensorMode::IP_ETHERNET } },
            format: { with: /\A\z|\A(([0-9A-Fa-f]{2})\-){5}(([0-9A-Fa-f]{2}))$|^(([0-9A-Fa-f]{2})\:){5}(([0-9A-Fa-f]{2}))\z/ }

  validates_numericality_of :target_port, greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN, less_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MAX, allow_nil: true, only_integer: true
  validates :target_port,
            presence: { if: proc { |sensor| sensor.mode_id.to_i == System::SensorMode::HEPv3 } }

  validates_numericality_of :hep_capture_id, greater_than_or_equal_to: 0, less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_INT, allow_nil: true, only_integer: true

  before_save :on_save_change_empty_to_null

  def on_save_change_empty_to_null
    # Convert empty string to NULL for nullable fields with non string type
    %w[source_interface target_mac target_ip source_ip].map do |el|
      self[el] = nil if self[el].blank?
    end
    # Temporary disable "use_routing". Dima.s requested this 19.11.2014
    self.use_routing = false
  end

  # for active admin creation form
  def hep_target_ip
    self[:target_ip]
  end

  include Yeti::SensorReloader

  def display_name
    name.to_s
  end
end
