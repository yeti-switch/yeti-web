# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer          not null, primary key
#  name :string
#

class DisconnectPolicy < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error, foreign_key: :orig_disconnect_policy_id
  #belongs_to :policy_code
  
  self.table_name='disconnect_policy'
  
  has_paper_trail class_name: 'AuditLogItem'


  validates_presence_of :name
  validates_uniqueness_of  :name, allow_blank: false

  def display_name
    "#{self.name} | #{self.id}"
  end

  include Yeti::TranslationReloader

end
