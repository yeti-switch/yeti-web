# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::ChartOriginatedCpsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :chart_originated_cps

  let!(:account) { create(:account, contractor: customer).reload }
  let!(:another_account) { create(:account, contractor: customer).reload }
  before do
    Cdr::Cdr.where(customer_acc_id: account.id).delete_all

    create_list :cdr, 4,
                customer_acc_id: account.id,
                routing_attempt: 1,
                time_start: '2019-01-01 00:00:00'

    create_list :cdr, 2,
                customer_acc_id: account.id,
                routing_attempt: 1,
                time_start: '2019-01-01 00:00:59'

    create_list :cdr, 12,
                customer_acc_id: account.id,
                routing_attempt: 1,
                time_start: '2019-01-01 23:59:59'

    # not first routing attempt
    create :cdr,
           customer_acc_id: account.id,
           routing_attempt: 2,
           time_start: '2019-01-01 15:34:00'

    # created_at out of scope
    create :cdr,
           customer_acc_id: account.id,
           time_start: '2019-01-02 00:00:00'

    create :cdr,
           customer_acc_id: account.id,
           time_start: '2018-12-31 23:59:59'

    # different account
    create :cdr,
           customer_acc_id: another_account.id,
           time_start: '2019-01-01 12:00:01'
  end

  describe 'POST /api/rest/customer/v1/chart-originated-cps' do
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
            'cps': [
              { x: '0.1', y: Time.parse('2019-01-01 00:00:00').utc.to_s(:db) },
              { x: '0.2', y: Time.parse('2019-01-01 23:59:00').utc.to_s(:db) }
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
