# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::ActiveCallsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :active_calls

  let!(:account) { create(:account, contractor: customer).reload }
  let!(:another_account) { create(:account, contractor: customer).reload }
  before do
    Stats::ActiveCallAccount.where(account_id: account.id).delete_all

    create :active_call_account,
           account: account,
           originated_count: 10,
           terminated_count: 15,
           created_at: '2019-01-01 00:00:01'

    create :active_call_account,
           account: account,
           originated_count: 17,
           terminated_count: 13,
           created_at: '2019-01-01 15:15:00'

    # created_at out of scope
    create :active_call_account,
           account: account,
           originated_count: 100,
           terminated_count: 150,
           created_at: '2019-01-02 00:00:01'

    # different account
    create :active_call_account,
           account: another_account,
           originated_count: 76,
           terminated_count: 89,
           created_at: '2019-01-01 00:00:01'
  end

  describe 'POST /api/rest/customer/v1/active-calls' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_attributes) do
      { 'from-time': '2019-01-01 00:00:00', 'to-time': '2019-01-02 00:00:00' }
    end
    let(:json_api_relationships) do
      { account: { data: { id: account.uuid, type: 'accounts' } } }
    end

    it_behaves_like :json_api_check_authorization

    context 'success' do
      include_examples :returns_json_api_record, relationships: [:account], status: 201 do
        let(:json_api_record_id) { be_present }
        let(:json_api_record_attributes) do
          {
            'from-time': Time.parse('2019-01-01 00:00:00').iso8601(3),
            'to-time': Time.parse('2019-01-02 00:00:00').iso8601(3),
            'originated-calls': [
              { x: 10, y: Time.parse('2019-01-01 00:00:01').utc.to_s(:db) },
              { x: 17, y: Time.parse('2019-01-01 15:15:00').utc.to_s(:db) }
            ],
            'terminated-calls': [
              { x: 15, y: Time.parse('2019-01-01 00:00:01').utc.to_s(:db) },
              { x: 13, y: Time.parse('2019-01-01 15:15:00').utc.to_s(:db) }
            ]
          }
        end
      end
    end

    context 'when Account not exists' do
      let(:json_api_relationships) do
        { account: { data: { id: SecureRandom.uuid, type: 'accounts' } } }
      end

      include_examples :returns_json_api_errors, errors: {
        detail: "account - can't be blank"
      }
    end

    context 'when Account from another customer' do
      let(:json_api_relationships) do
        { account: { data: { id: other_account.uuid, type: 'accounts' } } }
      end

      let!(:other_api_access) { create :api_access, api_access_attrs }
      let(:other_customer) { other_api_access.customer }
      let!(:other_account) { create(:account, contractor: other_customer).reload }

      include_examples :returns_json_api_errors, errors: {
        detail: "account - can't be blank"
      }
    end
  end
end
