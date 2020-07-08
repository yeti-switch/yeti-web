# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.areas
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  areas_name_key  (name) UNIQUE
#

class Routing::Area < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name = 'class4.areas'

  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :prefixes, class_name: 'Routing::AreaPrefix', foreign_key: :area_id, dependent: :delete_all
  has_many :src_detection_rules, class_name: 'Routing::RoutingTagDetectionRule', foreign_key: :src_area_id, dependent: :restrict_with_error
  has_many :dst_detection_rules, class_name: 'Routing::RoutingTagDetectionRule', foreign_key: :dst_area_id, dependent: :restrict_with_error

  def display_name
    "#{name} | #{id}"
  end
end
