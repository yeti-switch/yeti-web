# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_types
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#  uuid :uuid             not null
#
# Indexes
#
#  network_types_name_key  (name) UNIQUE
#  network_types_uuid_key  (uuid) UNIQUE
#

class System::NetworkType < ApplicationRecord
  self.table_name = 'sys.network_types'

  module CONST
    NETWORK_TYPE_LANDLINE = 'Landline'
    NETWORK_TYPE_MOBILE = 'Mobile'
    NETWORK_TYPE_SP = 'Supplementary services'
    NETWORK_TYPE_PR = 'Premium-rate, global telecommunication service'
    NETWORK_TYPE_UIFN = 'UIFN'
    NETWORK_TYPE_SATELLITE = 'Satellite'
    NETWORK_TYPE_SHORT_CODE = 'Short Code'
    NETWORK_TYPE_MOBILE_PAGING = 'Mobile/Paging'
    NETWORK_TYPE_PAGING = 'Paging'

    NETWORK_TYPE_PRIORITIES = [NETWORK_TYPE_LANDLINE,
                               NETWORK_TYPE_MOBILE,
                               NETWORK_TYPE_SP,
                               NETWORK_TYPE_PR,
                               NETWORK_TYPE_UIFN,
                               NETWORK_TYPE_SATELLITE,
                               NETWORK_TYPE_SHORT_CODE,
                               NETWORK_TYPE_MOBILE_PAGING,
                               NETWORK_TYPE_PAGING].freeze
  end

  has_many :networks, class_name: 'System::Network', foreign_key: :type_id, dependent: :restrict_with_exception

  validates :name, uniqueness: { allow_blank: true }, presence: true

  def display_name
    name
  end

  def self.collection
    order(:name)
  end
end
