# frozen_string_literal: true

class BatchUpdateForm::CustomersAuth < BatchUpdateForm::Base
  model_class 'CustomersAuth'
  attribute :enabled, type: :boolean
  attribute :reject_calls, type: :boolean
  attribute :transport_protocol_id, type: :foreign_key, class_name: 'Equipment::TransportProtocol'
  attribute :src_number_min_length
  attribute :src_number_max_length
  attribute :dst_number_min_length
  attribute :dst_number_max_length
  attribute :dump_level_id, type: :integer_collection, collection: CustomersAuth::DUMP_LEVELS.invert.to_a
  attribute :dst_numberlist_id, type: :foreign_key, class_name: 'Routing::Numberlist'
  attribute :src_numberlist_id, type: :foreign_key, class_name: 'Routing::Numberlist'
  attribute :rateplan_id, type: :foreign_key, class_name: 'Routing::Rateplan'
  attribute :routing_plan_id, type: :foreign_key, class_name: 'Routing::RoutingPlan'
  attribute :lua_script_id, type: :foreign_key, class_name: 'System::LuaScript'

  # number & name translations
  attribute :src_name_field_id, type: :integer_collection, collection: CustomersAuth::SRC_NAME_FIELDS.invert.to_a
  attribute :src_name_rewrite_rule
  attribute :src_name_rewrite_result
  attribute :src_number_field_id, type: :integer_collection, collection: CustomersAuth::SRC_NUMBER_FIELDS.invert.to_a
  attribute :src_rewrite_rule
  attribute :src_rewrite_result
  attribute :dst_number_field_id, type: :integer_collection, collection: CustomersAuth::DST_NUMBER_FIELDS.invert.to_a
  attribute :dst_rewrite_rule
  attribute :dst_rewrite_result

  # privacy
  attribute :privacy_mode_id, type: :integer_collection, collection: CustomersAuth::PRIVACY_MODES.invert.to_a
  attribute :diversion_policy_id, type: :integer_collection, collection: CustomersAuth::DIVERSION_POLICIES.invert.to_a
  attribute :pai_policy_id, type: :integer_collection, collection: CustomersAuth::PAI_POLICIES.invert.to_a

  # required with
  validates :src_number_min_length, required_with: :src_number_max_length, if: -> { src_number_min_length.nil? || src_number_max_length.nil? }
  validates :dst_number_min_length, required_with: :dst_number_max_length, if: -> { dst_number_min_length.nil? || dst_number_max_length.nil? }

  # presence
  validates :src_number_min_length, presence: true, if: :src_number_min_length_changed?
  validates :src_number_max_length, presence: true, if: :src_number_max_length_changed?
  validates :dst_number_min_length, presence: true, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, presence: true, if: :dst_number_max_length_changed?

  # inclusion. Values of :integer_collection attributes reach the form as strings,
  # so the allowed keys have to be compared as strings too.
  validates :dump_level_id, inclusion: { in: CustomersAuth::DUMP_LEVELS.keys.map(&:to_s) }, if: :dump_level_id_changed?
  validates :src_name_field_id, inclusion: { in: CustomersAuth::SRC_NAME_FIELDS.keys.map(&:to_s) }, if: :src_name_field_id_changed?
  validates :src_number_field_id, inclusion: { in: CustomersAuth::SRC_NUMBER_FIELDS.keys.map(&:to_s) }, if: :src_number_field_id_changed?
  validates :dst_number_field_id, inclusion: { in: CustomersAuth::DST_NUMBER_FIELDS.keys.map(&:to_s) }, if: :dst_number_field_id_changed?
  validates :privacy_mode_id, inclusion: { in: CustomersAuth::PRIVACY_MODES.keys.map(&:to_s) }, if: :privacy_mode_id_changed?
  validates :diversion_policy_id, inclusion: { in: CustomersAuth::DIVERSION_POLICIES.keys.map(&:to_s) }, if: :diversion_policy_id_changed?
  validates :pai_policy_id, inclusion: { in: CustomersAuth::PAI_POLICIES.keys.map(&:to_s) }, if: :pai_policy_id_changed?

  # numericality
  validates :src_number_max_length, numericality: {
    greater_than_or_equal_to: :src_number_min_length,
    less_than_or_equal_to: 100,
    allow_blank: true,
    only_integer: true
  }, if: -> { src_number_max_length_changed? && src_number_min_length =~ /^[0-9]+$/ }

  validates :src_number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    only_integer: true,
    allow_blank: true
  }, if: :src_number_min_length_changed?

  validates :dst_number_max_length, numericality: {
    greater_than_or_equal_to: :dst_number_min_length,
    less_than_or_equal_to: 100,
    allow_blank: true,
    only_integer: true
  }, if: -> { dst_number_max_length_changed? && dst_number_min_length =~ /^[0-9]+$/ }

  validates :dst_number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    only_integer: true,
    allow_blank: true
  }, if: :dst_number_min_length_changed?
end
