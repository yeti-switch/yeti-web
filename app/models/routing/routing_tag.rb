class Routing::RoutingTag < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name='class4.routing_tags'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :detection_rules, class_name: Routing::RoutingTagDetectionRule, foreign_key: :routing_tag_id, dependent: :restrict_with_error
  has_many :destinations, class_name: Destination, foreign_key: :routing_tag_id, dependent: :restrict_with_error
  has_many :dialpeers, class_name: Dialpeer, foreign_key: :routing_tag_id, dependent: :restrict_with_error

  def display_name
    "#{self.name} | #{self.id}"
  end

end
