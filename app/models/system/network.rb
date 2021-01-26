# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.networks
#
#  id      :integer(4)       not null, primary key
#  name    :string           not null
#  uuid    :uuid             not null
#  type_id :integer(2)       not null
#
# Indexes
#
#  networks_name_key  (name) UNIQUE
#  networks_uuid_key  (uuid) UNIQUE
#
# Foreign Keys
#
#  networks_type_id_fkey  (type_id => network_types.id)
#

class System::Network < Yeti::ActiveRecord
  self.table_name = 'sys.networks'

  has_many :prefixes, class_name: 'System::NetworkPrefix'
  belongs_to :network_type, class_name: 'System::NetworkType', foreign_key: :type_id

  validates :name, uniqueness: { allow_blank: true }, presence: true
  validates :network_type, presence: true

  def display_name
    "#{id} | #{name}"
  end

  def self.collection
    order(:name)
  end
end
