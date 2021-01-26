# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy
#
#  id   :integer(4)       not null, primary key
#  name :string
#
# Indexes
#
#  disconnect_code_policy_name_key  (name) UNIQUE
#

class DisconnectPolicy < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error, foreign_key: :orig_disconnect_policy_id
  # belongs_to :policy_code

  self.table_name = 'disconnect_policy'

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }

  def display_name
    "#{name} | #{id}"
  end

  include Yeti::TranslationReloader
end
