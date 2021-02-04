# frozen_string_literal: true

class Routing::RateGroupDuplicatorForm
  include ActiveModel::Model

  attr_accessor :name, :id

  validates :name, :id, presence: true

  validate do
    errors.add(:id, :invalid) unless Routing::RateGroup.exists?(id)
    errors.add(:name, :taken) if Routing::RateGroup.exists?(name: name)
  end

  def save
    if valid?
      Routing::RateGroup.transaction do
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
  end

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  def self.inheritance_column
    nil
  end
end
