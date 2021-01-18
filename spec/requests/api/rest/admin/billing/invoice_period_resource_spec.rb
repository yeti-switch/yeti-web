# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Billing::InvoicePeriodController, type: :request do
  include_context :json_api_admin_helpers, type: :'invoice-period'

  describe 'GET /api/rest/admin/billing/invoice-period-resources' do
    subject do
      get '/api/rest/admin/billing/invoice-period', params: nil, headers: json_api_request_headers
    end

    let!(:invoice_periods) do
      Billing::InvoicePeriod.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        invoice_periods.map { |r| r.id.to_s }
      end
    end
  end
end
