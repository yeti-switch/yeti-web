# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CryptomusPaymentsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'cryptomus-payments'

  let!(:account) { create(:account, contractor: customer) }
  let!(:prev_payment) { create(:payment, account:) }

  describe 'POST /api/rest/customer/v1/cryptomus-payments' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_successfully do
      it 'creates pending payment' do
        expect { subject }.to change { Payment.count }.by(1)
        expect(Payment.last).to have_attributes(
                                  account_id: account.id,
                                  amount: json_api_attributes[:amount].to_d,
                                  notes: json_api_attributes[:notes],
                                  status_id: Payment::CONST::STATUS_ID_PENDING,
                                  private_notes: nil
                                )
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { account.reload.balance }
      end

      include_examples :responds_with_status, 201

      it 'responds with payment uuid' do
        subject
        expect(response_json).to match(
                                   data: {
                                     id: Payment.last.uuid,
                                     type: 'cryptomus-payments',
                                     attributes: {
                                       url: cryptomus_url
                                     },
                                     links: anything
                                   }
                                 )
      end
    end

    shared_examples :creation_failed do |errors:|
      include_examples :returns_json_api_errors, errors: errors

      it 'does not create payment' do
        expect(CryptomusPayment::Create).not_to receive(:call)
        expect { subject }.not_to change { Payment.count }
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { account.reload.balance }
      end
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'cryptomus-payments',
          attributes: json_api_attributes,
          relationships: json_api_relationships
        }
      }
    end
    let(:json_api_attributes) do
      { amount: '100' }
    end
    let(:json_api_relationships) do
      {
        account: { data: { type: 'accounts', id: account.reload.uuid } }
      }
    end
    let(:cryptomus_url) do
      'https://pay.cryptomus.com/pay/f1386fb5-ecfa-41d4-a85d-b151d98df5e1'
    end

    before do
      allow(CryptomusPayment::Create).to receive(:call).with(
        order_id: (prev_payment.id + 1),
        amount: json_api_attributes[:amount].to_d
      ).and_return(cryptomus_url)
    end

    include_examples :creates_successfully

    context 'with notes attribute' do
      let(:json_api_attributes) do
        super().merge notes: 'qweasd'
      end

      include_examples :creates_successfully
    end

    context 'with no attributes and no relationships' do
      let(:json_api_attributes) { {} }
      let(:json_api_relationships) { {} }

      include_examples :creation_failed, errors: [
        { detail: "amount - can't be blank", source: { pointer: '/data/attributes/amount' } },
        { detail: "account - can't be blank", source: { pointer: '/data/relationships/account' } }
      ]
    end
  end
end
