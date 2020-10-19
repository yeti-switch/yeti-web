# frozen_string_literal: true

# == Schema Information
#
# Table name: pops
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  pop_name_key  (name) UNIQUE
#

class Pop < ActiveRecord::Base
  has_many :nodes, dependent: :restrict_with_error
  has_many :customer_auths, class_name: 'CustomersAuth', foreign_key: :pop_id, dependent: :restrict_with_error
  has_many :gateways, class_name: 'Gateway', foreign_key: :pop_id, dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'

  validates :id, :name, uniqueness: true
  validates :id, :name, presence: true
end
