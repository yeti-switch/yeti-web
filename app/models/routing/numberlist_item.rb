# == Schema Information
#
# Table name: class4.numberlist_items
#
#  id                 :integer          not null, primary key
#  numberlist_id      :integer          not null
#  key                :string           not null
#  created_at         :datetime
#  updated_at         :datetime
#  action_id          :integer
#  src_rewrite_rule   :string
#  src_rewrite_result :string
#  dst_rewrite_rule   :string
#  dst_rewrite_result :string
#

class Routing::NumberlistItem < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'

  self.table_name='class4.numberlist_items'

  belongs_to :numberlist, class_name: Routing::Numberlist, foreign_key: :numberlist_id
  belongs_to :action, class_name: Routing::NumberlistAction, foreign_key: :action_id


  validates_uniqueness_of :key, scope: [ :numberlist_id ]

  def display_name
    "#{self.key} | #{self.id}"
  end

end
