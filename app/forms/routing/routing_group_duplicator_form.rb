# frozen_string_literal: true

class Routing::RoutingGroupDuplicatorForm < ApplicationForm

  attribute :name
  attribute :id

  validates :name, :id, presence: true

  validate do
    errors.add(:name, :invalid) unless RoutingGroup.exists?(id)
    errors.add(:name, :taken) if RoutingGroup.exists?(name: name)
  end

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  def self.inheritance_column
    nil
  end

  private

  def _save
    RoutingGroup.create!(name: name)
  end
end
