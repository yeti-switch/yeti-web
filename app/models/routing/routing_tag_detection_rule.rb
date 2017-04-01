# == Schema Information
#
# Table name: class4.routing_tag_detection_rules
#
#  id             :integer          not null, primary key
#  src_area_id    :integer
#  dst_area_id    :integer
#  routing_tag_id :integer          not null
#

class Routing::RoutingTagDetectionRule < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name='class4.routing_tag_detection_rules'

  validates_presence_of :routing_tag_id

  belongs_to :src_area, class_name: Routing::Area, foreign_key: :src_area_id
  belongs_to :dst_area, class_name: Routing::Area, foreign_key: :dst_area_id
  belongs_to :routing_tag, class_name: Routing::RoutingTag, foreign_key: :routing_tag_id

  def display_name
    "#{self.id}"
  end

end
