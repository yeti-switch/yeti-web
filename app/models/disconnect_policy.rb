# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer          not null, primary key
#  name :string
#

class DisconnectPolicy < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error, foreign_key: :orig_disconnect_policy_id
  # belongs_to :policy_code

  self.table_name = 'disconnect_policy'

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }

  def display_name
    "#{name} | #{id}"
  end

  include Yeti::TranslationReloader
end
