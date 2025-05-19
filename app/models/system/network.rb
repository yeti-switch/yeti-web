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

class System::Network < ApplicationRecord
  self.table_name = 'sys.networks'

  has_many :prefixes, class_name: 'System::NetworkPrefix'
  belongs_to :network_type, class_name: 'System::NetworkType', foreign_key: :type_id

  validates :name, uniqueness: { allow_blank: true }, presence: true
  validates :network_type, presence: true

  scope :country_id_eq, lambda { |country_id|
    network_id_select = System::NetworkPrefix.where(country_id: country_id).select(:network_id)
    where(id: network_id_select)
  }

  scope :search_for, ->(term) { where("networks.name || ' | ' || networks.id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  include WithPaperTrail

  def display_name
    "#{name} | #{id}"
  end

  def self.collection
    order(:name)
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      country_id_eq
      search_for ordered_by
    ]
  end
end
