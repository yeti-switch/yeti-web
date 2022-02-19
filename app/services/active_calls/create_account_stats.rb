# frozen_string_literal: true

module ActiveCalls
  class CreateAccountStats < ApplicationService
    parameter :customer_calls, required: true
    parameter :vendor_calls, required: true
    parameter :current_time, required: true

    def call
      attrs_list = build_calls_attrs_list
      calls_account_ids = (customer_calls.keys + vendor_calls.keys).uniq
      missing_account_ids = Account.where.not(id: calls_account_ids).pluck(:id)
      attrs_list.concat build_empty_attrs_list(missing_account_ids)
      return if attrs_list.empty?

      Stats::ActiveCallAccount.insert_all!(attrs_list)
    end

    private

    def build_calls_attrs_list
      calls = Hash.new do |list, key|
        list[key] = {
          terminated_count: 0,
          originated_count: 0,
          created_at: current_time,
          account_id: key
        }
      end
      customer_calls.each do |account_id, sub_calls|
        calls[account_id.to_i][:originated_count] = sub_calls.count
      end
      vendor_calls.each do |account_id, sub_calls|
        calls[account_id.to_i][:terminated_count] = sub_calls.count
      end
      calls.values
    end

    def build_empty_attrs_list(account_ids)
      account_ids.map do |account_id|
        {
          terminated_count: 0,
          originated_count: 0,
          created_at: current_time,
          account_id: account_id
        }
      end
    end
  end
end
