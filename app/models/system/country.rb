# == Schema Information
#
# Table name: sys.countries
#
#  id   :integer          not null, primary key
#  name :string           not null
#  iso2 :string(2)        not null
#

class System::Country < Yeti::ActiveRecord
  self.table_name = 'sys.countries'
  has_many :prefixes, class_name: 'System::NetworkPrefix'
  has_many :networks, -> { uniq },  through: :prefixes

  def display_name
    "#{self.name}"
  end

  def self.collection
    order(:name)
  end


end
