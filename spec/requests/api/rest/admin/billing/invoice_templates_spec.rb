# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Billing::InvoiceTemplateController, type: :request do
  include_context :json_api_admin_helpers, type: :'invoice-templates', prefix: '/api/rest/admin/billing'

  let(:json_api_request_path) { "#{json_api_request_path_prefix}/invoice-template" }

  describe 'GET /api/rest/admin/billing/invoice-template' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:invoice_templates) do
      FactoryBot.create_list(:invoice_template, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        invoice_templates.map { |r| r.id.to_s }
      end
    end
  end
end
