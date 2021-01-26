# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destination_next_rates
#
#  id               :bigint(8)        not null, primary key
#  applied          :boolean          default(FALSE), not null
#  apply_time       :datetime
#  connect_fee      :decimal(, )      not null
#  initial_interval :integer(2)       not null
#  initial_rate     :decimal(, )      not null
#  next_interval    :integer(2)       not null
#  next_rate        :decimal(, )      not null
#  created_at       :datetime
#  updated_at       :datetime
#  destination_id   :bigint(8)        not null
#  external_id      :bigint(8)
#
# Foreign Keys
#
#  destination_next_rates_destination_id_fkey  (destination_id => destinations.id)
#

class Routing::DestinationNextRate < Yeti::ActiveRecord
  self.table_name = 'class4.destination_next_rates'

  validates :destination, presence: true
  validates :next_rate,
                        :initial_rate,
                        :initial_interval,
                        :next_interval,
                        :connect_fee,
                        :apply_time, presence: true

  validates :initial_interval, :next_interval, numericality: { greater_than: 0 } # we have DB constraints for this
  validates :next_rate, :initial_rate, :connect_fee, numericality: true

  belongs_to :destination, class_name: 'Routing::Destination'

  scope :not_applied, -> { where(applied: false) }
  scope :applied, -> { where(applied: true) }

  scope :ready_for_apply, lambda {
    not_applied.where('apply_time < ?', Time.now.utc).preload(:destination)
  }
end
