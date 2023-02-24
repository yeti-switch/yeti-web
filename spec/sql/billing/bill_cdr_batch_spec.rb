# frozen_string_literal: true

RSpec.describe 'billing.bill_cdr_batch' do
  subject do
    SqlCaller::Yeti.select_all('SELECT * FROM billing.bill_cdr_batch(?,?)', batch_id, batch_data).map(&:deep_symbolize_keys)
  end

  let(:batch_id) { 1 }

  let(:customer_acc1) {
    FactoryBot.create(:account, balance: 0)
  }

  let(:customer_acc2) {
    FactoryBot.create(:account, balance: 0)
  }

  let(:vendor_acc1) {
    FactoryBot.create(:account, balance: 0)
  }

  let(:vendor_acc2) {
    FactoryBot.create(:account, balance: 0)
  }

  let(:dp) {
    FactoryBot.create(:dialpeer)
  }

  let(:gw) {
    FactoryBot.create(:gateway)
  }

  let(:batch_data) do
    [
      {
        customer_acc_id: customer_acc1.id,
        customer_price: 10,
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc1.id,
        vendor_price: 1100,
        dialpeer_reverse_billing: false,
        dialpeer_id: dp.id,
        term_gw_id: -11, # there is no such gw
        duration: 10
      },
      {
        customer_acc_id: customer_acc1.id,
        customer_price: 3.999,
        destination_reverse_billing: true,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: 1120,
        dialpeer_reverse_billing: false,
        dialpeer_id: dp.id,
        term_gw_id: gw.id,
        duration: 22
      },
      {
        customer_acc_id: customer_acc1.id,
        customer_price: -110, # should be ignored
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: 0.99999,
        dialpeer_reverse_billing: true,
        dialpeer_id: dp.id,
        term_gw_id: gw.id,
        duration: 0
      },
      {
        customer_acc_id: customer_acc2.id,
        customer_price: 11,
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: -555, # should be ignored
        dialpeer_reverse_billing: false,
        dialpeer_id: dp.id,
        term_gw_id: gw.id,
        duration: -11 # should be skipped in stats
      }
    ].to_json.to_s
  end

  it 'responds with correct rows' do
    subject
    expect(Account.find(customer_acc1.id).balance).to eq -6.001
    expect(Account.find(customer_acc2.id).balance).to eq -11
    expect(Account.find(vendor_acc1.id).balance).to eq 1100
    expect(Account.find(vendor_acc2.id).balance).to eq 1120 - 0.99999

    ds = Dialpeer.find(dp.id).statistic
    expect(ds.calls).to eq 3
    expect(ds.calls_success).to eq 2
    expect(ds.calls_fail).to eq 1
    expect(ds.total_duration).to eq 32
    expect(ds.asr).to eq 0.6666667
    expect(ds.acd).to eq 16

    gs = Gateway.find(gw.id).statistic
    expect(gs.calls).to eq 2
    expect(gs.calls_success).to eq 1
    expect(gs.calls_fail).to eq 1
    expect(gs.total_duration).to eq 22
    expect(gs.asr).to eq 0.5
    expect(gs.acd).to eq 22
  end
end
