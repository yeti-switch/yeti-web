# frozen_string_literal: true

# == Schema Information
#
# Table name: dialpeer_next_rates
#
#  id               :integer          not null, primary key
#  dialpeer_id      :integer          not null
#  next_rate        :decimal(, )      not null
#  initial_interval :integer          not null
#  next_interval    :integer          not null
#  connect_fee      :decimal(, )      not null
#  apply_time       :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime
#  applied          :boolean          default(FALSE), not null
#  external_id      :integer
#  initial_rate     :decimal(, )      not null
#

class DialpeerNextRate < Yeti::ActiveRecord
  validates :dialpeer, presence: true
  validates :next_rate,
                        :initial_rate,
                        :initial_interval,
                        :next_interval,
                        :connect_fee,
                        :apply_time, presence: true

  validates :initial_interval, :next_interval, numericality: { greater_than: 0 } # we have DB constraints for this
  validates :next_rate, :initial_rate, :connect_fee, numericality: true

  belongs_to :dialpeer

  scope :not_applied, -> { where(applied: false) }
  scope :applied, -> { where(applied: true) }

  has_paper_trail class_name: 'AuditLogItem'

  scope :ready_for_apply, lambda {
    not_applied.where('apply_time < ?', Time.now.utc).preload(:dialpeer)
  }
end
