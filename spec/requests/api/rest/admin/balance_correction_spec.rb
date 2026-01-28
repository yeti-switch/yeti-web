# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::BalanceCorrectionController do
  include_context :json_api_admin_helpers, type: :'balance-correction'

  describe 'PUT /api/rest/admin/accounts/:id/balance-correction' do
    subject do
      put json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let!(:initial_balance) { 991 }

    let(:account) { FactoryBot.create(:account, balance: initial_balance) }
    let(:json_api_request_path_prefix) { "/api/rest/admin/accounts/#{account.id}" }

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          id: account.id.to_s,
          attributes: json_api_request_attributes
        }
      }
    end
    let(:json_api_request_attributes) do
      {
        'correction': -22.11
      }
    end

    include_examples :returns_json_api_record, status: 200 do
      let(:json_api_record_id) { account.id.to_s }
      let(:json_api_record_attributes) do
        {
          'balance': (initial_balance + json_api_request_attributes[:correction]).to_s, # decimal rendered as string
          'correction': nil,
          'name': account.name
        }
      end
    end

    it_behaves_like :json_api_admin_check_authorization, status: 200

    it 'changes account balance' do
      subject
      expect(account.reload).to have_attributes(
                                  balance: initial_balance + json_api_request_attributes[:correction]
                                )
    end
  end
end
