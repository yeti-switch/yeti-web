# frozen_string_literal: true

# == Schema Information
#
# Table name: versions
#
#  id             :integer(4)       not null, primary key
#  event          :string(255)      not null
#  ip             :string(255)
#  item_type      :string(255)      not null
#  object         :text
#  object_changes :text
#  txid           :bigint(8)
#  whodunnit      :string(255)
#  created_at     :timestamptz
#  item_id        :bigint(8)        not null
#
# Indexes
#
#  index_versions_on_item_type_and_item_id  (item_type,item_id)
#

FactoryBot.define do
  factory :audit_log_item, class: AuditLogItem do
    item_type { 'Account' }
    association :item, factory: :account
    event { 'update' }
  end
end
