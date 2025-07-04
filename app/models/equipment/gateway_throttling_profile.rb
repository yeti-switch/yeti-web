# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_throttling_profiles
#
#  id              :integer(2)       not null, primary key
#  codes           :string           not null, is an Array
#  minimum_calls   :integer(2)       default(20), not null
#  name            :string           not null
#  threshold_end   :float(24)        not null
#  threshold_start :float(24)        not null
#  window          :integer(2)       not null
#
# Indexes
#
#  gateway_throttling_profiles_name_key  (name) UNIQUE
#
class Equipment::GatewayThrottlingProfile < ApplicationRecord
  self.table_name = 'class4.gateway_throttling_profiles'

  include WithPaperTrail
  include Yeti::StateUpdater
  self.state_names = %w[gateways_cache]

  has_many :gateways, class_name: 'Gateway', dependent: :restrict_with_error, inverse_of: :throttling_profile

  validates :name, presence: true, uniqueness: true

  validates :threshold_start, :threshold_end, presence: true, allow_blank: false, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 100
  }

  validates :threshold_end, numericality: { greater_than: :threshold_start }

  validates :window, presence: true, allow_blank: false, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 120,
    only_integer: true
  }

  validates :minimum_calls, presence: true, allow_blank: false, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: PG_MAX_SMALLINT,
    only_integer: true
  }

  validates :codes, presence: true
  validates :codes, array_format: {
    without: /\s/, message: 'spaces are not allowed',
    allow_nil: false
  }, array_uniqueness: { allow_nil: false }

  CODE_408_LOCAL = 'local408'
  CODE_408_REMOTE = '408'
  CODE_503 = '503'
  CODE_480 = '480'
  CODES = {
    CODE_408_LOCAL => 'Local 408',
    CODE_408_REMOTE => 'SIP 408',
    CODE_480 => 'SIP 480',
    CODE_503 => 'SIP 503'
  }.freeze

  def codes=(value)
    value = value.map(&:strip).reject(&:blank?)
    self[:codes] = value
  end

  def display_name
    "#{name} | #{id}"
  end
end
