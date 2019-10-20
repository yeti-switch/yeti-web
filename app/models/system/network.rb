# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.networks
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  type_id :integer          not null
#  uuid    :uuid             not null
#

class System::Network < Yeti::ActiveRecord
  self.table_name = 'sys.networks'

  has_many :prefixes, class_name: 'System::NetworkPrefix'
  belongs_to :network_type, class_name: 'System::NetworkType', foreign_key: :type_id

  validates :name, uniqueness: { allow_blank: true }, presence: true
  validates :network_type, presence: true

  has_paper_trail class_name: 'AuditLogItem'

  def display_name
    "#{id} | #{name}"
  end

  def self.collection
    order(:name)
  end
end
