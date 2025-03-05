# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destination_next_rates
#
#  id               :bigint(8)        not null, primary key
#  applied          :boolean          default(FALSE), not null
#  apply_time       :timestamptz
#  connect_fee      :decimal(, )      not null
#  initial_interval :integer(2)       not null
#  initial_rate     :decimal(, )      not null
#  next_interval    :integer(2)       not null
#  next_rate        :decimal(, )      not null
#  created_at       :timestamptz
#  updated_at       :timestamptz
#  destination_id   :bigint(8)        not null
#  external_id      :bigint(8)
#
# Indexes
#
#  destination_next_rates_destination_id_idx  (destination_id)
#
# Foreign Keys
#
#  destination_next_rates_destination_id_fkey  (destination_id => destinations.id)
#

class Routing::DestinationNextRate < ApplicationRecord
  self.table_name = 'class4.destination_next_rates'

  belongs_to :destination, class_name: 'Routing::Destination'

  validates :destination, presence: true
  validates :next_rate,
            :initial_rate,
            :initial_interval,
            :next_interval,
            :connect_fee,
            :apply_time,
            presence: true

  # we have DB constraints for this
  validates :initial_interval, :next_interval, numericality: {
    greater_than: 0,
    less_than_or_equal_to: ApplicationRecord::PG_MAX_SMALLINT
  }
  validates :next_rate, :initial_rate, :connect_fee, numericality: true

  scope :not_applied, -> { where(applied: false) }
  scope :applied, -> { where(applied: true) }

  include WithPaperTrail

  scope :ready_for_apply, lambda {
    not_applied.where('apply_time < ?', Time.now.utc).preload(
      destination: %i[
        rate_group
        routing_tag_mode
      ]
    )
  }

  def apply!
    transaction do
      destination.update!(
        # current_rate_id: rate.id,
        initial_interval: initial_interval,
        next_interval: next_interval,
        initial_rate: initial_rate,
        next_rate: next_rate,
        connect_fee: connect_fee
      )
      update!(applied: true)
    end
  end
end
