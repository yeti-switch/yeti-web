# frozen_string_literal: true

class Routing::RateGroupDuplicatorForm < ApplicationForm
  attribute :name, :string
  attribute :id, :integer

  validates :name, :id, presence: true

  validate do
    errors.add(:id, :invalid) unless Routing::RateGroup.exists?(id)
    errors.add(:name, :taken) if Routing::RateGroup.exists?(name: name)
  end

  private

  def _save
    dst = Routing::RateGroup.create!(
      name: name
    )
    src = Routing::RateGroup.find(id)
    src.destinations.each do |n|
      x = n.dup
      x.uuid = nil
      x.external_id = nil
      x.rate_group_id = dst.id
      x.save!
    end
  end
end
