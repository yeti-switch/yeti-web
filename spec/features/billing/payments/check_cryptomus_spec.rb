# frozen_string_literal: true

RSpec.describe 'Payments check cryptomus page', js: true do
  subject do
    visit payment_path(payment.id)
    click_link 'Check Cryptomus'
  end

  include_context :login_as_admin
  let!(:payment) { create(:payment, payment_attrs) }
  let(:payment_attrs) { { status_id: Payment::CONST::STATUS_ID_PENDING } }

  let!(:stub_cryptomus_payment) do
    WebMock.stub_request(:post, "#{Cryptomus::CONST::URL}/v1/payment/info")
           .with(
      headers: { 'Content-Type': 'application/json' },
      body: { order_id: payment.id.to_s }.to_json
    )
           .and_return(
      headers: { 'Content-Type': 'application/json' },
      status: cryptomus_response_status,
      body: cryptomus_response_body.to_json
    )
  end
  let(:cryptomus_response_status) { 200 }
  let(:cryptomus_response_body) do
    {
      "state": 0,
      "result": {
        "uuid": 'f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
        "order_id": payment.id.to_s,
        "amount": '100.00000000',
        "payment_amount": '110.95000000',
        "payer_amount": '100.00000000',
        "payer_currency": 'USDT',
        "currency": 'USDT',
        "comments": nil,
        "network": 'tron_trc20',
        "address": nil,
        "from": nil,
        "txid": nil,
        "payment_status": 'paid',
        "url": 'https://pay.cryptomus.com/pay/f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
        "expired_at": 1.hour.from_now.to_i,
        "status": 'paid',
        "is_final": true,
        "additional_data": nil,
        "currencies": [
          {
            "currency": 'USDT',
            "network": 'tron_trc20'
          },
          {
            "currency": 'USDT',
            "network": 'eth_erc20'
          }
        ]
      }
    }
  end

  let!(:stub_check_status) do
    allow(CryptomusPayment::CheckStatus).to receive(:call).with(payment:).once
  end

  it 'calls CryptomusPayment::CheckStatus' do
    expect(CryptomusPayment::CheckStatus).to receive(:call).with(payment:).once
    subject
    expect(page).to have_flash_message('Payment status updated.', type: :notice)
  end

  context 'when CryptomusPayment::CheckStatus::Error raised' do
    let!(:stub_check_status) do
      allow(CryptomusPayment::CheckStatus).to receive(:call).with(payment:).and_raise(
        CryptomusPayment::CheckStatus::Error, 'test error'
      )
    end

    it 'displays error' do
      subject
      expect(page).to have_flash_message('test error', type: :error)
    end
  end

  context 'when Cryptomus::Errors::ApiError raised' do
    let!(:stub_check_status) do
      response = double(status: 404, body: { error: 'not found' })
      allow(CryptomusPayment::CheckStatus).to receive(:call).with(payment:).and_raise(
        Cryptomus::Errors::ApiError, response
      )
    end

    it 'displays error' do
      subject
      expect(page).to have_flash_message('Response status 404', type: :error)
    end
  end
end
