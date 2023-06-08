# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Jobs::PrometheusCustomerAuthStats do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  let(:account1) { FactoryBot.create(:account, external_id: 1) }
  let(:account2) { FactoryBot.create(:account, external_id: 2) }
  let(:account3) { FactoryBot.create(:account, external_id: nil) }

  let(:customer_auth1) { FactoryBot.create(:customers_auth, account: account1, external_id: 4, external_type: 'test1') }
  let(:customer_auth2) { FactoryBot.create(:customers_auth, account: account2, external_id: 5, external_type: nil) }
  let(:customer_auth3) { FactoryBot.create(:customers_auth, account: account3, external_id: nil, external_type: nil) }

  let(:stats) do
    [
      Stats::CustomerAuthStats::StatRow.new(account_id: account1.id,
                                            account_external_id: account1.external_id,
                                            customer_auth_id: customer_auth1.id,
                                            customer_auth_external_id: customer_auth1.external_id,
                                            customer_auth_external_type: customer_auth1.external_type,
                                            customer_price: 0.3),
      Stats::CustomerAuthStats::StatRow.new(account_id: account2.id,
                                            account_external_id: account2.external_id,
                                            customer_auth_id: customer_auth2.id,
                                            customer_auth_external_id: customer_auth2.external_id,
                                            customer_auth_external_type: customer_auth2.external_type,
                                            customer_price: 0.4),
      Stats::CustomerAuthStats::StatRow.new(account_id: account3.id,
                                            account_external_id: account3.external_id,
                                            customer_auth_id: customer_auth3.id,
                                            customer_auth_external_id: customer_auth3.external_id,
                                            customer_auth_external_type: customer_auth3.external_type,
                                            customer_price: 0.5)
    ]
  end

  before do
    allow(Stats::CustomerAuthStats).to receive(:last24_hour).and_return(stats)
  end

  it 'sends prometheus metrics' do
    expect { subject }.to send_prometheus_metrics
      .exactly(3)
      .with(type: 'yeti_ac',
            last24h_customer_price: 0.3,
            metric_labels: {
              account_id: account1.id,
              account_external_id: account1.external_id,
              customer_auth_id: customer_auth1.id,
              customer_auth_external_id: customer_auth1.external_id,
              customer_auth_external_type: customer_auth1.external_type
            })
      .with(type: 'yeti_ac',
            last24h_customer_price: 0.4,
            metric_labels: {
              account_id: account2.id,
              account_external_id: account2.external_id,
              customer_auth_id: customer_auth2.id,
              customer_auth_external_id: customer_auth2.external_id,
              customer_auth_external_type: customer_auth2.external_type
            })
      .with(type: 'yeti_ac',
            last24h_customer_price: 0.5,
            metric_labels: {
              account_id: account3.id,
              account_external_id: account3.external_id,
              customer_auth_id: customer_auth3.id,
              customer_auth_external_id: customer_auth3.external_id,
              customer_auth_external_type: customer_auth3.external_type
            })
  end
end
