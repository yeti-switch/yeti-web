# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CustomerPortalAccessProfileController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :check_rates
  let(:json_api_request_path) { "#{json_api_request_path_prefix}/customer-portal-access-profile" }
  let!(:account) { create(:account, contractor: customer) }

  describe 'GET /api/rest/customer/v1/customer-portal-access-profile' do
    subject { get json_api_request_path, headers: json_api_request_headers }

    context 'when valid data' do
      it 'returns 200' do
        subject

        expect(response.status).to eq(200)
        expect(response_json[:data]).to a_hash_including(
          id: anything,
          type: 'customer-portal-access-profiles',
          attributes: {
            name: api_access.customer_portal_access_profile.name,
            account: true,
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
            'incoming-cdrs': true,
            'incoming-statistics': true,
            'invoices': true,
            'payments': true,
            'services': true,
            'transactions': true
          }
        )
      end
    end
  end
end
