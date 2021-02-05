# frozen_string_literal: true

class Routing::RateGroupDuplicatorForm < ApplicationForm

  attribute :name
  attribute :id

  validates :name, :id, presence: true

  validate do
    errors.add(:id, :invalid) unless Routing::RateGroup.exists?(id)
    errors.add(:name, :taken) if Routing::RateGroup.exists?(name: name)
  end

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  def self.inheritance_column
    nil
  end

  private

  def _save
    Routing::RateGroup.create!(name: name)
  end
end
