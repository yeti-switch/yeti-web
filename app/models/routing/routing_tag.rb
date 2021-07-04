# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tags
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_tags_name_key  (name) UNIQUE
#

class Routing::RoutingTag < ApplicationRecord
  include WithPaperTrail
  self.table_name = 'class4.routing_tags'

  ANY_TAG = 'any tag'

  has_many :customers_auths, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'CustomersAuth', autosave: false
  has_many :numberlists, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::Numberlist', autosave: false
  has_many :numberlist_items, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::NumberlistItem', autosave: false

  has_many :detection_rules, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::RoutingTagDetectionRule', autosave: false
  has_many :dialpeers, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.routing_tag_ids)", tag.id) }, class_name: 'Dialpeer', autosave: false
  has_many :destinations, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.routing_tag_ids)", tag.id) }, class_name: 'Routing::Destination', autosave: false

  validates :name,
            presence: true,
            uniqueness: true,
            exclusion: { in: [ANY_TAG] },
            format: { with: /\A[^\s][^,]+?[^\s]\z/ } # not allow: ',' and start/end spaces

  before_destroy :prevent_destroy_if_have_assosiations

  def display_name
    "#{name} | #{id}"
  end

  private

  def prevent_destroy_if_have_assosiations
    if has_active_assosiations?
      raise ActiveRecord::RecordNotDestroyed,
            'Can not be deleted. Has related Customers Auth'
    end
  end

  def has_active_assosiations?
    customers_auths.any? ||
      numberlists.any? ||
      numberlist_items.any? ||
      detection_rules.any? ||
      dialpeers.any? ||
      destinations.any?
  end
end
