# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_types
#
#  id   :integer          not null, primary key
#  name :string           not null
#  uuid :uuid             not null
#

class System::NetworkType < Yeti::ActiveRecord
  self.table_name = 'sys.network_types'

  has_many :networks, class_name: 'System::Network', foreign_key: :type_id, dependent: :restrict_with_exception

  validates :name, uniqueness: { allow_blank: true }, presence: true

  def display_name
    name
  end

  def self.collection
    order(:name)
  end
end
