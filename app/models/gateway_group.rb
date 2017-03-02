# == Schema Information
#
# Table name: gateway_groups
#
#  id              :integer          not null, primary key
#  vendor_id       :integer          not null
#  name            :string           not null
#  prefer_same_pop :boolean          default(TRUE), not null
#

class GatewayGroup < ActiveRecord::Base
  
  belongs_to :vendor, -> { where vendor: true }, class_name: 'Contractor'
  has_many :gateways, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'



  validates_presence_of :name
  validates_uniqueness_of :name, allow_blank: false
  validates_presence_of :vendor

  def display_name
    "#{self.name} | #{self.id}"
  end

  def have_valid_gateways?
    gateways.where("enabled and allow_termination").count>0
  end

end
