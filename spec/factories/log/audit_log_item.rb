# frozen_string_literal: true

# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  item_type      :string(255)      not null
#  item_id        :integer          not null
#  event          :string(255)      not null
#  whodunnit      :string(255)
#  object         :text
#  created_at     :datetime
#  ip             :string(255)
#  object_changes :text
#  txid           :integer
#

FactoryBot.define do
  factory :audit_log_item, class: AuditLogItem do
    item_type { 'Account' }
    association :item, factory: :account
    event { 'update' }
  end
end
