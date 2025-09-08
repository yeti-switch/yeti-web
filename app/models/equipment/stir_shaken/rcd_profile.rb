# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_rcd_profiles
#
#  id          :integer(4)       not null, primary key
#  apn         :string
#  icn         :string
#  jcd         :jsonb
#  jcl         :string
#  nam         :string           not null
#  created_at  :timestamptz
#  updated_at  :timestamptz
#  external_id :bigint(8)
#  mode_id     :integer(2)       default(1), not null
#
class Equipment::StirShaken::RcdProfile < ApplicationRecord
  self.table_name = 'class4.stir_shaken_rcd_profiles'

  include WithPaperTrail

  MODE_INJECT = 1
  MODES = {
    MODE_INJECT => 'Inject'
  }.freeze

  validates :mode_id, inclusion: { in: MODES.keys }, allow_nil: false
  validates :nam, :mode_id, presence: true
  validates :icn, :jcl, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  before_validation { self.jcd = nil if jcd.blank? }
  validate :validate_jcd

  include Yeti::StateUpdater
  self.state_names = ['stir_shaken_rcd_profiles']

  def display_name
    "#{nam} | #{id}"
  end

  def mode_name
    MODES[mode_id]
  end

  def jcd_json=(value)
    self.jcd = value.blank? ? nil : JSON.parse(value)
  rescue JSON::ParserError
    # need to show invalid variables JSON as is in new/edit form.
    self.jcd = value
  end

  def jcd_json
    return if jcd.nil?
    # need to show invalid variables JSON as is in new/edit form.
    return jcd if jcd.is_a?(String)

    JSON.generate(jcd)
  end

  private

  def validate_jcd
    if !jcd.nil? && !jcd.is_a?(Hash)
      errors.add(:jcd, 'must be a JSON object or empty')
    end
  end
end
