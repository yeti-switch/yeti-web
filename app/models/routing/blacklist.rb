# == Schema Information
#
# Table name: blacklists
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime
#  updated_at :datetime
#

class Routing::Blacklist < ActiveRecord::Base
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name='class4.blacklists'

  belongs_to :mode, class_name: BlacklistMode, foreign_key: :mode_id
  has_many :routing_blacklist_items, class_name: Routing::BlacklistItem, foreign_key: :blacklist_id, dependent: :delete_all

  validates_presence_of :mode, :name
  validates_uniqueness_of :name

  def display_name
    "#{self.name} | #{self.id}"
  end

end
