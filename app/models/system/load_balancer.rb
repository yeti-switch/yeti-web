# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.load_balancers
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  signalling_ip :string           not null
#

class System::LoadBalancer < Yeti::ActiveRecord
  self.table_name = 'sys.load_balancers'

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, :signalling_ip, presence: true
  validates :name, :signalling_ip, uniqueness: true
end
