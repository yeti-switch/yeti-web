# frozen_string_literal: true

require 'spec_helper'

require File.join(File.dirname(__FILE__), '../../processors/cdr_billing')
require File.join(File.dirname(__FILE__), '../../models/routing_base')

RSpec.describe CdrBilling do
  CONFIG = begin
    f = YAML.safe_load(ERB.new(File.read('../config/database.yml')).result, aliases: true)
    {
      'mode' => 'test',
      'databases' => f.to_h
    }
  end

  # fake models, since we have no access to main project
  class Account < ::RoutingBase
    self.table_name = 'billing.accounts'
    establish_connection(CONFIG['databases']['test'])
  end

  class Contractor < ::RoutingBase
    self.table_name = 'public.contractors'
    establish_connection(CONFIG['databases']['test'])
  end

  let(:cdrs) do
    [
      {
        id: 1,
        dialpeer_reverse_billing: vendor_reverse,
        vendor_price: 5.0,
        vendor_acc_id: vendor_acc.id,
        destination_reverse_billing: customer_reverse,
        customer_price: 10.0,
        customer_acc_id: customer_acc.id
      }
    ]
  end

  let(:vendor_reverse) { false }
  let(:customer_reverse) { false }

  let(:logger) do
    double('Logger::Syslog')
  end

  let(:consumer) do
    described_class.new(logger,
                        'cdr_billing',
                        'cdr_billin',
                        CONFIG)
  end

  let(:contractor) do
  end

  let(:vendor_acc) do
    Account.create!(
      contractor_id: Contractor.create!(vendor: true).id,
      balance: 100,
      min_balance: 0,
      max_balance: 200,
      name: 'acc_vendor'
    )
  end

  let(:customer_acc) do
    Account.create!(
      contractor_id: Contractor.create!(customer: true).id,
      balance: 100,
      min_balance: 0,
      max_balance: 200,
      name: 'acc_customer'
    )
  end

  before :each do
    Account.delete_all
    Contractor.delete_all
  end

  after :each do
    Account.delete_all
    Contractor.delete_all
  end

  before do
    # fake @batch_id
    consumer.instance_variable_set(:@batch_id, (Time.now.to_f * 1000).to_i)
  end

  subject { consumer.perform_group cdrs }

  context 'normal billing mode' do
    it 'customer balance changes by minus $10, vendor plus $5' do
      subject
      expect(vendor_acc.reload.balance).to eq(105)
      expect(customer_acc.reload.balance).to eq(90)
    end
  end

  context 'reverse billing for customer' do
    let(:customer_reverse) { true }

    it 'customer balance increase' do
      subject
      expect(vendor_acc.reload.balance).to eq(105)
      expect(customer_acc.reload.balance).to eq(110)
    end
  end

  context 'reverse billing for vendor' do
    let(:vendor_reverse) { true }

    it 'vendor balance decrease' do
      subject
      expect(vendor_acc.reload.balance).to eq(95)
      expect(customer_acc.reload.balance).to eq(90)
    end
  end
end
