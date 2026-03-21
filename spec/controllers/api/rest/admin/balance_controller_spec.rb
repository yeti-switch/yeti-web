# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::BalanceController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'PUT update', versioning: true do
    let(:balance) { 10 }
    let!(:account) { create(:account, balance: balance) }

    subject do
      put :update, params: {
        account_id: account.external_id, data: { type: 'balances', id: account.external_id, attributes: attributes }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { balance: 9.85 } }
      it 'should change balance' do
        expect { subject }.to change { account.reload.balance }.from(balance).to(attributes[:balance])
      end

      include_examples :does_not_create_audit_log

      context 'response' do
        before { subject }

        it { expect(response.status).to eq(200) }
      end
    end
  end
end
