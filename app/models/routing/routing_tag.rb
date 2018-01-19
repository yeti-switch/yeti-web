# == Schema Information
#
# Table name: class4.routing_tags
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::RoutingTag < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name='class4.routing_tags'

  validates_presence_of :name
  validates_uniqueness_of :name

  # TODO: remove this later
  has_many :detection_rules, class_name: Routing::RoutingTagDetectionRule, foreign_key: :routing_tag_id, dependent: :restrict_with_error
  has_many :destinations, class_name: Destination, foreign_key: :routing_tag_id, dependent: :restrict_with_error
  has_many :dialpeers, class_name: Dialpeer, foreign_key: :routing_tag_id, dependent: :restrict_with_error

  has_many :customers_auths, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'CustomersAuth', autosave: false
  has_many :numberlists, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::Numberlist', autosave: false
  has_many :numberlist_items, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::NumberlistItem', autosave: false
  # TODO: rename later
  has_many :routing_tag_detection_rules, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.tag_action_value)", tag.id) }, class_name: 'Routing::RoutingTagDetectionRule', autosave: false

  # TODO: rename when delete old version from above
  has_many :array_dialpeers, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.routing_tag_ids)", tag.id) }, class_name: 'Dialpeer', autosave: false
  has_many :array_destinations, ->(tag) { unscope(:where).where("? = ANY(#{table_name}.routing_tag_ids)", tag.id) }, class_name: 'Destination', autosave: false

  before_destroy :prevent_destroy_if_have_assosiations

  def display_name
    "#{self.name} | #{self.id}"
  end

  private

  def prevent_destroy_if_have_assosiations
    if  has_active_assosiations?
      raise ActiveRecord::RecordNotDestroyed,
            'Can not be deleted. Has related Customers Auth'
    end
  end

  def has_active_assosiations?
    customers_auths.any? ||
      numberlists.any? ||
      numberlist_items.any? ||
      routing_tag_detection_rules.any? ||
      array_dialpeers.any? ||
      array_destinations.any?
  end
end
