# == Schema Information
#
# Table name: blacklist_items
#
#  id           :integer          not null, primary key
#  blacklist_id :integer          not null
#  key          :string           not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Routing::BlacklistItem < ActiveRecord::Base
  has_paper_trail class_name: 'AuditLogItem'

  self.table_name='class4.blacklist_items'

  belongs_to :blacklist, class_name: Routing::Blacklist, foreign_key: :blacklist_id

  validates_uniqueness_of :key, scope: [ :blacklist_id ]


  def display_name
    "#{self.key} | #{self.id}"
  end

end
