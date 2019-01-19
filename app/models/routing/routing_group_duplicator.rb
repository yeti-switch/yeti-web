# frozen_string_literal: true

class Routing::RoutingGroupDuplicator
  include ActiveModel::Model

  attr_accessor :name, :id

  validates_presence_of :name, :id

  validate do
    errors.add(:name, :invalid) unless RoutingGroup.exists?(id)
    errors.add(:name, :taken) if RoutingGroup.exists?(name: name)
  end

  def save
    if valid?
      RoutingGroup.transaction do
        dst = RoutingGroup.create!(
          name: name
        )
        src = RoutingGroup.find(id)
        src.dialpeers.each do |n|
          x = n.dup
          x.routing_group_id = dst.id
          x.save!
          n.dialpeer_next_rates.each do |nn|
            xx = nn.dup
            xx.dialpeer_id = x.id
            xx.save!
          end
        end
      end
    end
  end

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  def self.inheritance_column
    nil
  end
end
