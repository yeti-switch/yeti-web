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
  attribute :dst_numberlist_id, type: :foreign_key, class_name: 'Routing::Numberlist'
  attribute :src_numberlist_id, type: :foreign_key, class_name: 'Routing::Numberlist'
  attribute :dump_level_id, type: :foreign_key, class_name: 'DumpLevel'
  attribute :rateplan_id, type: :foreign_key, class_name: 'Rateplan'
  attribute :routing_plan_id, type: :foreign_key, class_name: 'Routing::RoutingPlan'
  attribute :lua_script_id, type: :foreign_key, class_name: 'System::LuaScript'

  validates :src_number_min_length, required_with: :src_number_max_length
  validates :dst_number_min_length, required_with: :dst_number_max_length
  validates :src_number_min_length, numericality: true, presence: true, if: :src_number_min_length_changed?
  validates :dst_number_min_length, numericality: true, presence: true, if: :dst_number_min_length_changed?

  validates :src_number_max_length, presence: true, numericality: {
    greater_than_or_equal_to: ->(r) { r.src_number_min_length.to_i }
  }, if: :src_number_max_length_changed?

  validates :dst_number_max_length, presence: true, numericality: {
    greater_than_or_equal_to: ->(r) { r.dst_number_min_length.to_i }
  }, if: :dst_number_max_length_changed?
end
