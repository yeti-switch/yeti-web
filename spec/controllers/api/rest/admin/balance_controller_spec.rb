require 'spec_helper'

describe Api::Rest::Admin::BalanceController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'PUT update', versioning: true do
    let(:balance) do
      10
    end
    let!(:account) { create(:account, balance: balance) }

    subject do
      put :update, account_id: account.to_param, data: { type: 'balances', id: account.to_param , attributes: attributes }
    end

    context 'when attributes are valid' do
      let(:attributes) { { balance: 9.85 } }
      it 'should change balance' do
        expect {subject}.to change{ account.reload.balance }.from(balance).to(attributes[:balance])
      end
      it 'should skip audit log' do
        expect {subject}.not_to change{ AuditLogItem.count }
      end

      context 'response' do
        before { subject }

        it { expect(response.status).to eq(200) }
      end

    end


  end

end
