class Routing::RateplanDuplicator
  include ActiveModel::Model

  attr_accessor :profit_control_mode_id, :name, :id, :send_quality_alarms_to

  validates_presence_of :name, :profit_control_mode_id, :id

  validate do
    self.errors.add(:id, :invalid) if !Rateplan.exists?(id)
    self.errors.add(:name, :taken) if Rateplan.exists?(name: name)
  end


  def save
    if self.valid?
      Rateplan.transaction do
        dst=Rateplan.create!(
            profit_control_mode_id: profit_control_mode_id,
            name: name,
            send_quality_alarms_to: send_quality_alarms_to
        )
        src=Rateplan.find(id)
        src.destinations.each do |n|
          x=n.dup
          x.uuid = nil
          x.rateplan_id=dst.id
          x.save!
        end
      end
    end
  end

end
