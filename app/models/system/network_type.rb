# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_types
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  sorting_priority :integer(2)       default(999), not null
#  uuid             :uuid             not null
#
# Indexes
#
#  network_types_name_key  (name) UNIQUE
#  network_types_uuid_key  (uuid) UNIQUE
#

class System::NetworkType < ApplicationRecord
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
