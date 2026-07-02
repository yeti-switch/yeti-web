# frozen_string_literal: true

# attempt_fee is charged for the act of attempting to send a call to a vendor,
# regardless of whether the call connected, but only when the call was actually
# sent to a vendor. A set internal_disconnect_code_id means the call was rejected
# by routing (never sent), so the fee is charged only when it is null:
#   * vendor side (dialpeer_attempt_fee): once per CDR (every attempt is a CDR)
#   * customer side (destination_attempt_fee): once per call, on the is_last_cdr row
# These specs exercise the billing.bill_cdr logic via switch.writecdr, focusing on
# FAILED / 0-duration attempts (where connect_fee never charges) so the amounts are exact.
RSpec.describe 'switch.writecdr() attempt_fee billing' do
  subject { SqlCaller::Cdr.execute("SELECT switch.writecdr(#{writecdr_parameters});") }

  before do
    # disable amount rounding so expected values are exact
    System::CdrConfig.take!.update!(
      customer_amount_round_mode_id: 1,
      vendor_amount_round_mode_id: 1
    )
  end

  # --- knobs ---------------------------------------------------------------
  let(:is_last_cdr) { 't' }
  let(:routing_attempt) { 1 }
  let(:time_connect) { nil } # nil => unanswered/failed attempt (success=false, duration=0)
  let(:destination_attempt_fee) { '2.0' }
  let(:dialpeer_attempt_fee) { '3.0' }
  let(:customer_acc_vat) { '23.0' }
  let(:package_counter_id) { nil }
  # nil => not rejected by routing, i.e. the call was sent to a vendor
  let(:internal_disconnect_code_id) { nil }

  let(:time_start) { 10.minutes.ago }
  let(:leg_b_time) { time_start + 10.seconds }
  let(:time_end) { Time.now }

  let(:i_time_data) do
    {
      time_start: time_start.to_f,
      leg_b_time: leg_b_time.to_f,
      time_connect: time_connect&.to_f,
      time_end: time_end.to_f,
      time_1xx: (time_start + 5.seconds).to_f,
      time_18x: (time_start + 6.seconds).to_f,
      time_limit: 7200,
      isup_propagation_delay: 0
    }.to_json
  end

  let(:i_dynamic_fields) do
    {
      customer_id: 1105,
      vendor_id: 1755,
      customer_acc_id: 1886,
      vendor_acc_id: 32,
      customer_auth_id: 20_084,
      destination_id: 4_201_534,
      dialpeer_id: 1_376_789,
      orig_gw_id: 17,
      term_gw_id: 39,
      destination_initial_rate: '0.0001',
      destination_next_rate: '0.0001',
      destination_initial_interval: 60,
      destination_next_interval: 11,
      dialpeer_initial_interval: 12,
      dialpeer_next_interval: 13,
      dialpeer_next_rate: '1.0',
      dialpeer_initial_rate: '1.0',
      destination_fee: '0.0',
      dialpeer_fee: '0.0',
      destination_attempt_fee: destination_attempt_fee,
      dialpeer_attempt_fee: dialpeer_attempt_fee,
      customer_acc_check_balance: true,
      destination_reverse_billing: false,
      dialpeer_reverse_billing: false,
      customer_acc_vat: customer_acc_vat,
      package_counter_id: package_counter_id
    }.to_json
  end

  let(:writecdr_parameters) do
    %(
        't', '10', '3', '#{routing_attempt}', '#{is_last_cdr}',
        '1', '127.0.0.3', '7878', '127.0.0.5', '9090',
        '1', '127.0.0.3', '7687', '127.0.0.99', '88888',
        'sip:ruri@example.com', 'sip:proxy@example.com',
        '#{i_time_data}',
        'f', '486', 'Busy', '3', '486', 'Busy', '486', 'Busy',
        #{internal_disconnect_code_id ? "'#{internal_disconnect_code_id}'" : 'NULL'},
        'orig-call-id@rspec', 'term-call-id@rspec',
        'local-tag-#{routing_attempt}', 'legb-local-tag-#{routing_attempt}',
        '', '0', 'f', '{}', '[]', '', '', '[]',
        NULL, NULL, NULL,
        '{"core":"1","yeti":"1","aleg":"a","bleg":"b"}',
        'f',
        '#{i_dynamic_fields}',
        '{"reason":{"q850_cause":16,"q850_text":"x","q850_params":"y"}}',
        '{"reason":{"q850_cause":32,"q850_text":"x","q850_params":"y"}}',
        '[]'
      )
  end

  let(:cdr) { Cdr::Cdr.last }
  let(:vat_multiplier) { 1 + BigDecimal(customer_acc_vat) / 100 }

  it 'writes one CDR row even for a failed attempt' do
    expect { subject }.to change { Cdr::Cdr.count }.by(1)
  end

  context 'failed attempt, last CDR of the call (is_last_cdr = true)' do
    it 'charges the customer the attempt fee once (with VAT) and the vendor once' do
      subject
      expect(cdr).to have_attributes(
        success: false,
        duration: 0,
        is_last_cdr: true,
        # customer: destination_attempt_fee, VAT applied like connect_fee
        customer_price_no_vat: BigDecimal(destination_attempt_fee),
        customer_price: BigDecimal(destination_attempt_fee) * vat_multiplier,
        # vendor: dialpeer_attempt_fee, no VAT
        vendor_price: BigDecimal(dialpeer_attempt_fee)
      )
    end
  end

  context 'failed attempt, NOT the last CDR (is_last_cdr = false)' do
    let(:is_last_cdr) { 'f' }

    it 'charges the vendor per CDR but NOT the customer' do
      subject
      expect(cdr).to have_attributes(
        is_last_cdr: false,
        customer_price: 0,
        customer_price_no_vat: 0,
        vendor_price: BigDecimal(dialpeer_attempt_fee)
      )
    end
  end

  context 'package call (package_counter_id present), last CDR' do
    let(:package_counter_id) { 777 }

    it 'skips the customer attempt fee but still charges the vendor' do
      subject
      expect(cdr).to have_attributes(
        customer_price: 0,
        customer_price_no_vat: 0,
        vendor_price: BigDecimal(dialpeer_attempt_fee)
      )
    end
  end

  context 'call was rejected by routing / not sent to a vendor (internal_disconnect_code_id present)' do
    let(:internal_disconnect_code_id) { 8034 }

    it 'charges neither the customer nor the vendor an attempt fee' do
      subject
      expect(cdr).to have_attributes(
        internal_disconnect_code_id: 8034,
        customer_price: 0,
        customer_price_no_vat: 0,
        vendor_price: 0,
        profit: 0
      )
    end
  end

  context 'no attempt fees configured (snapshots are 0)' do
    let(:destination_attempt_fee) { '0.0' }
    let(:dialpeer_attempt_fee) { '0.0' }

    it 'is a no-op: failed attempt stays fully zero-priced' do
      subject
      expect(cdr).to have_attributes(
        customer_price: 0,
        customer_price_no_vat: 0,
        vendor_price: 0,
        profit: 0
      )
    end
  end
end
