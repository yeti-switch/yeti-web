# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_items
#
#  id                   :integer(4)       not null, primary key
#  defer_dst_rewrite    :boolean          default(FALSE), not null
#  defer_src_rewrite    :boolean          default(FALSE), not null
#  dst_rewrite_result   :string
#  dst_rewrite_rule     :string
#  key                  :string           not null
#  number_max_length    :integer(2)       default(100), not null
#  number_min_length    :integer(2)       default(0), not null
#  src_rewrite_result   :string
#  src_rewrite_rule     :string
#  tag_action_value     :integer(2)       default([]), not null, is an Array
#  created_at           :timestamptz
#  updated_at           :timestamptz
#  action_id            :integer(2)
#  lua_script_id        :integer(2)
#  numberlist_id        :integer(4)       not null
#  rewrite_ss_status_id :integer(2)
#  tag_action_id        :integer(2)
#
# Indexes
#
#  blacklist_items_blacklist_id_key_idx  (numberlist_id,key) UNIQUE
#  numberlist_items_prefix_range_idx     (((key)::prefix_range)) USING gist
#
# Foreign Keys
#
#  blacklist_items_blacklist_id_fkey    (numberlist_id => numberlists.id)
#  numberlist_items_lua_script_id_fkey  (lua_script_id => lua_scripts.id)
#  numberlist_items_tag_action_id_fkey  (tag_action_id => tag_actions.id)
#

class Routing::NumberlistItem < ApplicationRecord
  include WithPaperTrail

  self.table_name = 'class4.numberlist_items'

  ACTION_REJECT = 1
  ACTION_ACCEPT = 2
  ACTIONS = {
    ACTION_REJECT => 'Reject call',
    ACTION_ACCEPT => 'Allow call'
  }.freeze

  belongs_to :numberlist, class_name: 'Routing::Numberlist', foreign_key: :numberlist_id

  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true
  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  validates :key, uniqueness: { scope: [:numberlist_id] }

  validates :number_min_length, :number_max_length, presence: true
  validates :number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :numberlist, presence: true
  validates :action_id, inclusion: { in: ACTIONS.keys }, allow_nil: true
  validates :rewrite_ss_status_id, inclusion: { in: Equipment::StirShaken::Attestation::ATTESTATIONS.keys }, allow_nil: true

  validates_with TagActionValueValidator

  attr_accessor :batch_key

  scope :where_customer, lambda { |id|
    numberlist_ids = CustomersAuth.where(customer_id: id).pluck(:dst_numberlist_id)
    where(numberlist_id: numberlist_ids)
  }

  scope :where_account, lambda { |id|
    numberlist_ids = CustomersAuth.where(account_id: id).pluck(:dst_numberlist_id)
    where(numberlist_id: numberlist_ids)
  }

  before_create do
    if batch_key.present?
      keys = batch_key.delete(' ').split(',').uniq
      while keys.length > 1
        new_instance = dup
        new_instance.batch_key = nil
        new_instance.key = keys.pop
        new_instance.save!
      end
      self.key = keys.pop
    elsif key.nil?
      self.key = ''
    end
  end

  def display_name
    "#{key} | #{id}"
  end

  def action_name
    action_id.nil? ? 'Default action' : ACTIONS[action_id]
  end

  def rewrite_ss_status_name
    rewrite_ss_status_id.nil? ? nil : Equipment::StirShaken::Attestation::ATTESTATIONS[rewrite_ss_status_id]
  end
end
