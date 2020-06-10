# frozen_string_literal: true

class Routing::RateplanDuplicator
  include ActiveModel::Model

  attr_accessor :profit_control_mode_id, :name, :id, :send_quality_alarms_to

  validates :name, :profit_control_mode_id, :id, presence: true

  validate do
    errors.add(:id, :invalid) unless Rateplan.exists?(id)
    errors.add(:name, :taken) if Rateplan.exists?(name: name)
  end

  def save
    if valid?
      Rateplan.transaction do
        dst = Rateplan.create!(
          profit_control_mode_id: profit_control_mode_id,
          name: name,
          send_quality_alarms_to: send_quality_alarms_to
        )
        src = Rateplan.find(id)
        src.destinations.each do |n|
          x = n.dup
          x.uuid = nil
          x.rateplan_id = dst.id
          x.save!
        end
      end
    end
  end

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  def self.inheritance_column
    nil
  end
end
