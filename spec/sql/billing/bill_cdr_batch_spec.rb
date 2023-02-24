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

  let(:batch_data) do
    [
      {
        customer_acc_id: customer_acc1.id,
        customer_price: 10,
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc1.id,
        vendor_price: 1100,
        dialpeer_reverse_billing: false
      },
      {
        customer_acc_id: customer_acc1.id,
        customer_price: 3.999,
        destination_reverse_billing: true,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: 1120,
        dialpeer_reverse_billing: false
      },
      {
        customer_acc_id: customer_acc1.id,
        customer_price: -110, # should be ignored
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: 0.99999,
        dialpeer_reverse_billing: true
      },
      {
        customer_acc_id: customer_acc2.id,
        customer_price: 11,
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc2.id,
        vendor_price: -555, #should be ignored
        dialpeer_reverse_billing: false
      },
    ].to_json.to_s
  end

  it 'responds with correct rows' do
    subject
    expect(Account.find(customer_acc1.id).balance).to eq -6.001
    expect(Account.find(customer_acc2.id).balance).to eq -11
    expect(Account.find(vendor_acc1.id).balance).to eq 1100
    expect(Account.find(vendor_acc2.id).balance).to eq 1120-0.99999
  end
end
