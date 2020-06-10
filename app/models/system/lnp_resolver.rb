# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lnp_resolvers
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  address :string           not null
#  port    :integer          not null
#

class System::LnpResolver < Yeti::ActiveRecord
  self.table_name = 'sys.lnp_resolvers'
  validates :name, uniqueness: true
  validates :name, :address, :port, presence: true

  has_paper_trail class_name: 'AuditLogItem'

  def display_name
    name.to_s
  end
end
