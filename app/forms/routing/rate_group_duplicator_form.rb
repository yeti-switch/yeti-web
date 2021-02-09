# frozen_string_literal: true

class Routing::RateGroupDuplicatorForm < ApplicationForm
  attribute :name, :string
  attribute :id, :integer

  validates :name, :id, presence: true

  validate do
    errors.add(:id, :invalid) if src_rate_group.nil?
    errors.add(:name, :taken) if Routing::RateGroup.exists?(name: name)
  end

  def src_rate_group
    return @src_rate_group if defined? @src_rate_group

    @src_rate_group = Routing::RateGroup.find_by(id: id)
  end

  private

  def _save
    dst = Routing::RateGroup.create!(
      name: name
    )
    src_rate_group.destinations.each do |n|
      x = n.dup
      x.uuid = nil
      x.external_id = nil
      x.rate_group_id = dst.id
      x.save!
    end
  end
end
