# frozen_string_literal: true

class BatchUpdateForm::Gateway < BatchUpdateForm::Base
  model_class 'Gateway'
  attribute :enabled, type: :boolean
  attribute :priority
  attribute :weight
  attribute :is_shared, type: :boolean
  attribute :acd_limit
  attribute :asr_limit
  attribute :short_calls_limit
  attribute :host

  # media
  attribute :filter_noaudio_streams, type: :boolean
  attribute :try_avoid_transcoding, type: :boolean
  attribute :proxy_media, type: :boolean
  attribute :single_codec_in_200ok, type: :boolean
  attribute :force_symmetric_rtp, type: :boolean
  attribute :symmetric_rtp_nonstop, type: :boolean
  attribute :rtp_ping, type: :boolean
  attribute :force_one_way_early_media, type: :boolean
  attribute :rtp_force_relay_cn, type: :boolean
  attribute :rtp_interface_name
  attribute :media_encryption_mode_id, type: :foreign_key, class_name: 'Equipment::GatewayMediaEncryptionMode'
  attribute :ice_mode_id, type: :integer_collection, collection: Gateway::ICE_MODES.invert.to_a
  attribute :rtcp_mux_mode_id, type: :integer_collection, collection: Gateway::RTCP_MUX_MODES.invert.to_a
  attribute :rtcp_feedback_mode_id, type: :integer_collection, collection: Gateway::RTCP_FEEDBACK_MODES.invert.to_a
  attribute :rtp_acl

  # presence
  validates :priority, presence: true, if: :priority_changed?
  validates :weight, presence: true, if: :weight_changed?
  validates :asr_limit, presence: true, if: :asr_limit_changed?
  validates :acd_limit, presence: true, if: :acd_limit_changed?

  # numericality
  validates :priority, numericality: {
    greater_than: 0,
    less_than_or_equal_to: ApplicationRecord::PG_MAX_SMALLINT,
    only_integer: true
  }, if: :priority_changed?
  validates :weight, numericality: {
    only_integer: true,
    less_than_or_equal_to: ApplicationRecord::PG_MAX_SMALLINT,
    greater_than: 0
  }, if: :weight_changed?
  validates :acd_limit, numericality: {
    greater_than_or_equal_to: 0.00
  }, if: :acd_limit_changed?
  validates :asr_limit, numericality: {
    less_than_or_equal_to: 1.00,
    greater_than_or_equal_to: 0.00
  }, if: :asr_limit_changed?
  validates :short_calls_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :short_calls_limit_changed?

  # media
  validates :rtp_interface_name, format: { without: /\s/, message: 'must contain no spaces' }, if: :rtp_interface_name_changed?

  validate if: :rtp_acl_changed? do
    rtp_acl.to_s.split(',').map(&:strip).reject(&:blank?).each do |raw_ip|
      IPAddr.new(raw_ip)
    rescue IPAddr::Error
      errors.add(:rtp_acl, "contains invalid ip or network: #{raw_ip}")
    end
  end
end
