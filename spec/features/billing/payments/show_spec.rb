# frozen_string_literal: true

RSpec.describe 'Payments show page', js: true do
  subject do
    visit payment_path(payment.id)
  end

  include_context :login_as_admin
  let!(:payment) { create(:payment, payment_attrs) }
  let(:payment_attrs) { {} }

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
        "payer_amount": '10.123123',
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

  context 'when payment is type=manual status=completed' do
    it 'displays payment details' do
      subject
      expect(page).to have_title("Payment ##{payment.id} | Yeti Admin", exact: true)
      expect(page).to have_page_title("Payment ##{payment.id}", exact: true)
      expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
      expect(page).to have_attribute_row 'AMOUNT', exact_text: payment.amount.to_s
      expect(page).to have_attribute_row 'TYPE', exact_text: 'MANUAL'
      expect(page).to have_attribute_row 'STATUS', exact_text: 'COMPLETED'
      expect(page).to have_attribute_row 'UUID', exact_text: payment.uuid
      expect(page).not_to have_selector(tab_header_link_selector, text: 'Cryptomus Info')
      expect(stub_cryptomus_payment).not_to have_been_requested
    end
  end

  context 'when payment is type=cryptomus' do
    let(:payment_attrs) { super().merge type_id: Payment::CONST::TYPE_ID_CRYPTOMUS }

    context 'when payment is status=pending' do
      let(:payment_attrs) { super().merge status_id: Payment::CONST::STATUS_ID_PENDING }

      it 'displays payment details' do
        subject
        expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
        expect(page).to have_attribute_row 'AMOUNT', exact_text: payment.amount.to_s
        expect(page).to have_attribute_row 'TYPE', exact_text: 'CRYPTOMUS'
        expect(page).to have_attribute_row 'STATUS', exact_text: 'PENDING'
        expect(page).to have_attribute_row 'UUID', exact_text: payment.uuid

        switch_tab 'Cryptomus Info'
        expect(page).to have_text(
                          JSON.pretty_generate(cryptomus_response_body)
                        )
        expect(stub_cryptomus_payment).to have_been_requested.once
      end

      context 'when cryptomus response with error' do
        let(:cryptomus_response_status) { 404 }
        let(:cryptomus_response_body) do
          { state: 1, message: 'No query results for model [App\\Models\\MerchantPayment].' }
        end

        it 'displays cryptomus payment' do
          subject
          expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
          switch_tab 'Cryptomus Info'
          expect(page).to have_text(
                            "Response status 404\n" + JSON.pretty_generate(cryptomus_response_body)
                          )
          expect(stub_cryptomus_payment).to have_been_requested.once
        end
      end
    end

    context 'when payment is status=completed' do
      let(:payment_attrs) { super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED }

      it 'displays payment details' do
        subject
        expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
        expect(page).to have_attribute_row 'AMOUNT', exact_text: payment.amount.to_s
        expect(page).to have_attribute_row 'TYPE', exact_text: 'CRYPTOMUS'
        expect(page).to have_attribute_row 'STATUS', exact_text: 'COMPLETED'
        expect(page).to have_attribute_row 'UUID', exact_text: payment.uuid

        switch_tab 'Cryptomus Info'
        expect(page).to have_text(
                          JSON.pretty_generate(cryptomus_response_body)
                        )
        expect(stub_cryptomus_payment).to have_been_requested.once
      end

      context 'when cryptomus response with error' do
        let(:cryptomus_response_status) { 404 }
        let(:cryptomus_response_body) do
          { state: 1, message: 'No query results for model [App\\Models\\MerchantPayment].' }
        end

        it 'displays cryptomus payment' do
          subject
          expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
          switch_tab 'Cryptomus Info'
          expect(page).to have_text(
                            "Response status 404\n" + JSON.pretty_generate(cryptomus_response_body)
                          )
          expect(stub_cryptomus_payment).to have_been_requested.once
        end
      end
    end

    context 'when payment is status=canceled' do
      let(:payment_attrs) { super().merge status_id: Payment::CONST::STATUS_ID_CANCELED }

      it 'displays payment details' do
        subject
        expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
        expect(page).to have_attribute_row 'AMOUNT', exact_text: payment.amount.to_s
        expect(page).to have_attribute_row 'TYPE', exact_text: 'CRYPTOMUS'
        expect(page).to have_attribute_row 'STATUS', exact_text: 'CANCELED'
        expect(page).to have_attribute_row 'UUID', exact_text: payment.uuid

        switch_tab 'Cryptomus Info'
        expect(page).to have_text(
                          JSON.pretty_generate(cryptomus_response_body)
                        )
        expect(stub_cryptomus_payment).to have_been_requested.once
      end

      context 'when cryptomus response with error' do
        let(:cryptomus_response_status) { 404 }
        let(:cryptomus_response_body) do
          { state: 1, message: 'No query results for model [App\\Models\\MerchantPayment].' }
        end

        it 'displays cryptomus payment' do
          subject
          expect(page).to have_attribute_row 'ID', exact_text: payment.id.to_s
          switch_tab 'Cryptomus Info'
          expect(page).to have_text(
                            "Response status 404\n" + JSON.pretty_generate(cryptomus_response_body)
                          )
          expect(stub_cryptomus_payment).to have_been_requested.once
        end
      end
    end
  end
end
