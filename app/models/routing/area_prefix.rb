class Routing::AreaPrefix < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'

  self.table_name='class4.area_prefixes'

  belongs_to :area, class_name: Routing::Area, foreign_key: :area_id

  validates_uniqueness_of :prefix
  validates_format_of :prefix, without: /\s/



  def display_name
    "#{self.prefix} | #{self.id}"
  end

end
