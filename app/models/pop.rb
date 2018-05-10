# == Schema Information
#
# Table name: pops
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Pop < ActiveRecord::Base
  has_many :nodes, dependent: :restrict_with_error
  has_many :customer_auths, class_name: 'CustomersAuth', foreign_key: :pop_id,  dependent: :restrict_with_error
  has_many :gateways, class_name: 'Gateway', foreign_key: :pop_id,  dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'
end
