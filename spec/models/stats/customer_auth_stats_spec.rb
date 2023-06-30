# frozen_string_literal: true

RSpec.describe Stats::CustomerAuthStats, type: :model do
  describe '.last24_hour', freeze_time: true do
    subject { described_class.last24_hour }

    let(:account) { FactoryBot.create(:account, external_id: 1) }
    let(:account_internal) { FactoryBot.create(:account, external_id: nil) }

    let(:customer_auth1) { FactoryBot.create(:customers_auth, **customer_auth1_attrs) }
    let(:customer_auth1_attrs) { { account: account, external_id: 2, external_type: 'test' } }

    let(:customer_auth2) { FactoryBot.create(:customers_auth, **customer_auth2_attrs) }
    let(:customer_auth2_attrs) { { account: account, external_id: 3, external_type: nil } }

    let(:customer_auth3) { FactoryBot.create(:customers_auth, **customer_auth3_attrs) }
    let(:customer_auth3_attrs) { { account: account_internal, external_id: nil, external_type: nil } }

    let(:timestamp_24_hours_ago) { 23.hours.ago.beginning_of_hour }
    let(:timestamp_now) { Time.now }
    let(:timestamp_early_than_24_hours) { 23.hours.ago.beginning_of_hour - 1.second }

    let!(:ca_stats1) do
      [
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth1, timestamp: timestamp_24_hours_ago, customer_price: 0.1),
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth1, timestamp: timestamp_now, customer_price: 0.2)
      ]
    end

    let!(:ca_stats2) do
      [
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth2, timestamp: timestamp_24_hours_ago, customer_price: 0.4),
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth2, timestamp: timestamp_now, customer_price: 0.3)
      ]
    end

    let!(:ca_stats3) do
      [
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth3, timestamp: timestamp_24_hours_ago, customer_price: 0.6),
        FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth3, timestamp: timestamp_now, customer_price: 0.1)
      ]
    end

    let(:expected_result) do
      [
        described_class::StatRow.new(account_id: account.id,
                                     account_external_id: account.external_id,
                                     customer_auth_id: customer_auth1.id,
                                     customer_auth_external_id: customer_auth1.external_id,
                                     customer_auth_external_type: customer_auth1.external_type,
                                     customer_price: ca_stats1.sum(&:customer_price)),
        described_class::StatRow.new(account_id: account.id,
                                     account_external_id: account.external_id,
                                     customer_auth_id: customer_auth2.id,
                                     customer_auth_external_id: customer_auth2.external_id,
                                     customer_auth_external_type: customer_auth2.external_type,
                                     customer_price: ca_stats2.sum(&:customer_price)),
        described_class::StatRow.new(account_id: account_internal.id,
                                     account_external_id: account_internal.external_id,
                                     customer_auth_id: customer_auth3.id,
                                     customer_auth_external_id: customer_auth3.external_id,
                                     customer_auth_external_type: customer_auth3.external_type,
                                     customer_price: ca_stats3.sum(&:customer_price))
      ]
    end

    before do
      # no cdrs
      FactoryBot.create(:customers_auth, external_id: 1011, external_type: 'em')

      ca_old_cdrs = FactoryBot.create(:customers_auth, external_id: 1012, external_type: 'term')

      # not in interval
      FactoryBot.create(:customer_auth_stats, customer_auth: customer_auth1, timestamp: timestamp_early_than_24_hours, customer_price: 1)
      FactoryBot.create(:customer_auth_stats, customer_auth: ca_old_cdrs, timestamp: timestamp_early_than_24_hours, customer_price: 1)

      # deleted customer_auth
      FactoryBot.create(:customer_auth_stats, customer_auth_id: 999_999, timestamp: timestamp_now, customer_price: 2)
    end

    it 'should return correct record' do
      expect(subject).to match_array(expected_result)
    end
  end
end
