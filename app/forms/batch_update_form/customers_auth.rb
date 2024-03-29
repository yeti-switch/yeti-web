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

  # required with
  validates :src_number_min_length, required_with: :src_number_max_length, if: -> { src_number_min_length.nil? || src_number_max_length.nil? }
  validates :dst_number_min_length, required_with: :dst_number_max_length, if: -> { dst_number_min_length.nil? || dst_number_max_length.nil? }

  # presence
  validates :src_number_min_length, presence: true, if: :src_number_min_length_changed?
  validates :src_number_max_length, presence: true, if: :src_number_max_length_changed?
  validates :dst_number_min_length, presence: true, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, presence: true, if: :dst_number_max_length_changed?

  # TODO: Why it doesn't work??
  # validates :dump_level_id, inclusion: { in: CustomersAuth::DUMP_LEVELS.keys }

  # numericality
  validates :src_number_max_length, numericality: {
    greater_than_or_equal_to: :src_number_min_length,
    less_than_or_equal_to: 100,
    allow_blank: true,
    only_integer: true
  }, if: -> { :src_number_max_length_changed? && src_number_min_length =~ /^[0-9]+$/ }

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
  }, if: -> { :dst_number_max_length_changed? && dst_number_min_length =~ /^[0-9]+$/ }

  validates :dst_number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    only_integer: true,
    allow_blank: true
  }, if: :dst_number_min_length_changed?
end
