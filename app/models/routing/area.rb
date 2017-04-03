# == Schema Information
#
# Table name: class4.areas
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::Area < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name='class4.areas'

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :prefixes, class_name: Routing::AreaPrefix, foreign_key: :area_id, dependent: :delete_all
  has_many :src_detection_rules, class_name: Routing::RoutingTagDetectionRule, foreign_key: :src_area_id, dependent: :restrict_with_error
  has_many :dst_detection_rules, class_name: Routing::RoutingTagDetectionRule, foreign_key: :dst_area_id, dependent: :restrict_with_error

  def display_name
    "#{self.name} | #{self.id}"
  end

end
