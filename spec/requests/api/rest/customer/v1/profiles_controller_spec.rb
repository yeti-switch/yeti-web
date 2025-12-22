# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::ProfilesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :check_rates
  let(:json_api_request_path) { "#{json_api_request_path_prefix}/profiles" }
  let!(:account) { create(:account, contractor: customer) }

  describe 'GET /api/rest/customer/v1/profiles' do
    subject { get json_api_request_path, headers: json_api_request_headers }

    context 'when valid data' do
      it 'returns 200' do
        subject

        expect(response.status).to eq(200)
        expect(response_json[:data]).to a_hash_including(
          id: anything,
          type: 'profiles',
          attributes: {
            'account': true,
            'outgoing-rateplans': true,
            'outgoing-cdrs': true,
            'outgoing-cdr-exports': true,

            'outgoing-statistics': true,
            'outgoing-statistics-active-calls': true,
            'outgoing-statistics-acd': true,
            'outgoing-statistics-asr': true,
            'outgoing-statistics-failed-calls': true,
            'outgoing-statistics-successful-calls': true,
            'outgoing-statistics-total-calls': true,
            'outgoing-statistics-total-duration': true,
            'outgoing-statistics-total-price': true,

            'outgoing-statistics-acd-value': true,
            'outgoing-statistics-asr-value': true,
            'outgoing-statistics-failed-calls-value': true,
            'outgoing-statistics-successful-calls-value': true,
            'outgoing-statistics-total-calls-value': true,
            'outgoing-statistics-total-duration-value': true,
            'outgoing-statistics-total-price-value': true,

            'outgoing-active-calls': true,
            'outgoing-numberlists': true,
            'incoming-cdrs': true,

            'incoming-statistics': true,
            'incoming-statistics-active-calls': true,
            'incoming-statistics-acd': true,
            'incoming-statistics-asr': true,
            'incoming-statistics-failed-calls': true,
            'incoming-statistics-successful-calls': true,
            'incoming-statistics-total-calls': true,
            'incoming-statistics-total-duration': true,
            'incoming-statistics-total-price': true,

            'incoming-statistics-acd-value': true,
            'incoming-statistics-asr-value': true,
            'incoming-statistics-failed-calls-value': true,
            'incoming-statistics-successful-calls-value': true,
            'incoming-statistics-total-calls-value': true,
            'incoming-statistics-total-duration-value': true,
            'incoming-statistics-total-price-value': true,

            'invoices': true,
            'payments': true,
            'payments-cryptomus': false,
            'services': true,
            'transactions': true
          }
        )
      end
    end
  end
end
