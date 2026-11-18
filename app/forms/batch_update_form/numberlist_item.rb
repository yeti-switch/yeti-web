# frozen_string_literal: true

class BatchUpdateForm::NumberlistItem < BatchUpdateForm::Base
  model_class 'Routing::NumberlistItem'

  attribute :number_min_length
  attribute :number_max_length
  attribute :action_id, type: :integer_collection, collection: Routing::NumberlistItem::ACTIONS.invert.to_a
  attribute :src_rewrite_rule
  attribute :src_rewrite_result
  attribute :defer_src_rewrite, type: :boolean
  attribute :dst_rewrite_rule
  attribute :dst_rewrite_result
  attribute :defer_dst_rewrite, type: :boolean
  attribute :tag_action_id, type: :foreign_key, class_name: 'Routing::TagAction'
  attribute :tag_action_value, type: :integer_collection, collection: proc { Routing::RoutingTag.order(:name).pluck(:name, :id) }
  attribute :rewrite_ss_status_id, type: :integer_collection, collection: Equipment::StirShaken::Attestation::ATTESTATIONS.invert.to_a
  attribute :lua_script_id, type: :foreign_key, class_name: 'System::LuaScript'
  attribute :variables_json

  validates :number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
    only_integer: true,
    allow_blank: true
  }, if: :number_min_length_changed?

  validates :number_max_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
    only_integer: true,
    allow_blank: true
  }, if: :number_max_length_changed?

  validates :action_id, inclusion: { in: Routing::NumberlistItem::ACTIONS.keys.map(&:to_s) }, if: :action_id_changed?
  validates :rewrite_ss_status_id, inclusion: { in: Equipment::StirShaken::Attestation::ATTESTATIONS.keys.map(&:to_s) }, if: :rewrite_ss_status_id_changed?
end
