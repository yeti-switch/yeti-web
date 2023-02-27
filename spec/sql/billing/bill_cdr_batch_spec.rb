# frozen_string_literal: true

RSpec.describe 'billing.bill_cdr_batch' do
  subject do
    SqlCaller::Yeti.execute('SELECT * FROM billing.bill_cdr_batch(?,?)', batch_id, batch_data.to_json)
  end

  let(:customer_acc1) { FactoryBot.create(:account, balance: 10) }
  let(:customer_acc2) { FactoryBot.create(:account, balance: 20) }
  let(:vendor_acc1) { FactoryBot.create(:account, balance: 30) }
  let(:vendor_acc2) { FactoryBot.create(:account, balance: 40) }
  let(:dp) { FactoryBot.create(:dialpeer) }
  let(:gw) { FactoryBot.create(:gateway) }

  let(:batch_id) { 1 }
  let(:batch_data) do
    [
      {
        customer_acc_id: customer_acc1.id,
        customer_price: 10,
        destination_reverse_billing: false,
        vendor_acc_id: vendor_acc1.id,
        vendor_price: 99,
        dialpeer_reverse_billing: false,
        dialpeer_id: -22, # there is no such dp
        term_gw_id: -11, # there is no such gw
        duration: 600
      },
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
    ]
  end

  it 'updates customer accounts' do
    customer_acc1_balance = customer_acc1.balance
    # destination_reverse_billing=false and customer_price > 0
    customer_acc1_spending = batch_data[0][:customer_price] + batch_data[1][:customer_price]
    # destination_reverse_billing=true and customer_price > 0
    customer_acc1_income = batch_data[2][:customer_price]

    customer_acc2_balance = customer_acc2.balance
    # destination_reverse_billing=false and customer_price > 0
    customer_acc2_spending = batch_data[4][:customer_price]

    subject
    expect(customer_acc1.reload.balance).to eq(customer_acc1_balance - customer_acc1_spending + customer_acc1_income)
    expect(customer_acc2.reload.balance).to eq(customer_acc2_balance - customer_acc2_spending)
  end

  it 'updates vendor accounts' do
    vendor_acc1_balance = vendor_acc1.balance
    # dialpeer_reverse_billing=false and vendor_price > 0
    vendor_acc1_income = batch_data[0][:vendor_price] + batch_data[1][:vendor_price]

    vendor_acc2_balance = vendor_acc2.balance
    # dialpeer_reverse_billing=false and vendor_price > 0
    vendor_acc2_income = batch_data[2][:vendor_price]
    # dialpeer_reverse_billing=true and vendor_price > 0
    vendor_acc2_spending = batch_data[3][:vendor_price]
    subject
    expect(vendor_acc1.reload.balance).to eq(vendor_acc1_balance + vendor_acc1_income)
    expect(vendor_acc2.reload.balance).to eq(vendor_acc2_balance + vendor_acc2_income - vendor_acc2_spending)
  end

  it 'updates statistic' do
    subject
    expect(dp.reload.statistic).to have_attributes(
                                     calls: 3,
                                     calls_success: 2,
                                     calls_fail: 1,
                                     total_duration: 32,
                                     asr: 0.6666667,
                                     acd: 16
                                   )

    expect(gw.reload.statistic).to have_attributes(
                                     calls: 2,
                                     calls_success: 1,
                                     calls_fail: 1,
                                     total_duration: 22,
                                     asr: 0.5,
                                     acd: 22
                                   )
  end

  context 'zero duration batch' do

    let(:batch_data) do
      [
        {
          customer_acc_id: customer_acc1.id,
          customer_price: 10,
          destination_reverse_billing: false,
          vendor_acc_id: vendor_acc1.id,
          vendor_price: 99,
          dialpeer_reverse_billing: false,
          dialpeer_id: -22, # there is no such dp
          term_gw_id: -11, # there is no such gw
          duration: 0
        },
        {
          customer_acc_id: customer_acc1.id,
          customer_price: 10,
          destination_reverse_billing: false,
          vendor_acc_id: vendor_acc1.id,
          vendor_price: 1100,
          dialpeer_reverse_billing: false,
          dialpeer_id: dp.id,
          term_gw_id: -11, # there is no such gw
          duration: 0
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
          duration: 0
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
      ]
    end

    it 'works' do
      subject
      expect(dp.reload.statistic).to have_attributes(
                                     calls: 3,
                                     calls_success: 0,
                                     calls_fail: 3,
                                     total_duration: 0,
                                     asr: 0,
                                     acd: 0
                                   )

      expect(gw.reload.statistic).to have_attributes(
                                     calls: 2,
                                     calls_success: 0,
                                     calls_fail: 2,
                                     total_duration: 0,
                                     asr: 0,
                                     acd: 0
                                   )

    end

  end

end
