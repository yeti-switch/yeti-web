# frozen_string_literal: true

module ActiveCalls
  class CreateAccountStats < ApplicationService
    parameter :customer_calls, required: true
    parameter :vendor_calls, required: true
    parameter :current_time, required: true

    def call
      attrs_list = build_calls_attrs_list
      return if attrs_list.empty?

      Stats::ActiveCallAccount.insert_all!(attrs_list)
    end

    private

    # Only accounts with active calls are stored (each row has originated_count
    # and/or terminated_count > 0). Absence of a row for a given snapshot means
    # zero — the chart reconstructs the zero baseline client-side.
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
  end
end
