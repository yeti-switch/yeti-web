# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_auth_profiles
#
#  id              :integer(2)       not null, primary key
#  attempts        :integer(2)       default(2), not null
#  name            :string           not null
#  port            :integer(4)       not null
#  reject_on_error :boolean          default(TRUE), not null
#  secret          :string           not null
#  server          :string           not null
#  timeout         :integer(2)       default(100), not null
#
# Indexes
#
#  radius_auth_profiles_name_key  (name) UNIQUE
#

class Equipment::Radius::AuthProfile < Yeti::ActiveRecord
  self.table_name = 'class4.radius_auth_profiles'

  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :radius_auth_profile_id, dependent: :restrict_with_error
  has_many :avps, class_name: 'Equipment::Radius::AuthProfileAttribute', foreign_key: :profile_id, inverse_of: :profile, dependent: :destroy

  accepts_nested_attributes_for :avps, allow_destroy: true

  TIMEOUT_MIN = 1
  TIMEOUT_MAX = 2000

  ATTEMPTS_MIN = 1
  ATTEMPTS_MAX = 10

  validates :name, uniqueness: true
  validates :name, :server, :port, :secret, :timeout, :attempts, presence: true

  validates :timeout, numericality: { greater_than_or_equal_to: TIMEOUT_MIN, less_than_or_equal_to: TIMEOUT_MAX, allow_nil: true, only_integer: true }
  validates :attempts, numericality: { greater_than_or_equal_to: ATTEMPTS_MIN, less_than_or_equal_to: ATTEMPTS_MAX, allow_nil: true, only_integer: true }
  validates :port, numericality: { greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN, less_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MAX, allow_nil: true, only_integer: true }

  before_save do
    Event.reload_radius_auth_profiles
  end

  after_destroy do
    Event.reload_radius_auth_profiles
  end

  def set_reject_on_error
    self.reject_on_error = true
    save!
  end

  def unset_reject_on_error
    self.reject_on_error = false
    save!
  end

  def display_name
    "#{id} | #{name}"
  end
end
