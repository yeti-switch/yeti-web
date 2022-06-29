# frozen_string_literal: true

RSpec.describe StatsAggregation::ActiveCallAccount, freeze_time: Time.zone.parse('2021-04-10 12:00:00') do
  subject do
    described_class.call
  end

  let!(:accounts) do
    FactoryBot.create_list(:account, 3)
  end

  let!(:stats) do
    [
      FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 10, terminated_count: 21, created_at: Time.zone.parse('2021-04-01 00:01:10')),

      FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 11, terminated_count: 0, created_at: Time.zone.parse('2021-04-09 10:00:00')),

      FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 10, terminated_count: 24, created_at: Time.zone.parse('2021-04-09 11:00:00')),
      FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 50, terminated_count: 13, created_at: Time.zone.parse('2021-04-09 11:31:18')),
      FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 6, terminated_count: 23, created_at: Time.zone.parse('2021-04-09 11:59:59')),

      FactoryBot.create(:active_call_account, account: accounts[1], originated_count: 15, terminated_count: 26, created_at: Time.zone.parse('2021-04-09 02:34:49')),

      FactoryBot.create(:active_call_account, account: accounts[1], originated_count: 16, terminated_count: 27, created_at: Time.zone.parse('2021-04-09 11:00:01'))
    ]
  end

  before do
    # not aggregated because created later than 1 day ago
    FactoryBot.create(:active_call_account, account: accounts[0], originated_count: 100, created_at: Time.zone.parse('2021-04-09 12:00:00'))
    FactoryBot.create(:active_call_account, account: accounts[2], terminated_count: 101, created_at: Time.zone.parse('2021-04-10 00:00:00'))
  end

  it 'creates correct aggregated active call stats' do
    expect { subject }.to change { Stats::AggActiveCallAccount.count }.by(5)

    agg_stat1 = Stats::AggActiveCallAccount.find_by! account_id: accounts[0].id, calls_time: Time.zone.parse('2021-04-01 00:00:00')
    expect(agg_stat1).to have_attributes(
                           avg_originated_count: 10,
                           max_originated_count: 10,
                           min_originated_count: 10,
                           avg_terminated_count: 21,
                           max_terminated_count: 21,
                           min_terminated_count: 21
                         )

    agg_stat2 = Stats::AggActiveCallAccount.find_by! account_id: accounts[0].id, calls_time: Time.zone.parse('2021-04-09 10:00:00')
    expect(agg_stat2).to have_attributes(
                           avg_originated_count: 11,
                           max_originated_count: 11,
                           min_originated_count: 11,
                           avg_terminated_count: 0,
                           max_terminated_count: 0,
                           min_terminated_count: 0
                         )

    agg_stat3 = Stats::AggActiveCallAccount.find_by! account_id: accounts[0].id, calls_time: Time.zone.parse('2021-04-09 11:00:00')
    expect(agg_stat3).to have_attributes(
                           avg_originated_count: 22,
                           max_originated_count: 50,
                           min_originated_count: 6,
                           avg_terminated_count: 20,
                           max_terminated_count: 24,
                           min_terminated_count: 13
                         )

    agg_stat4 = Stats::AggActiveCallAccount.find_by! account_id: accounts[1].id, calls_time: Time.zone.parse('2021-04-09 02:00:00')
    expect(agg_stat4).to have_attributes(
                           avg_originated_count: 15,
                           max_originated_count: 15,
                           min_originated_count: 15,
                           avg_terminated_count: 26,
                           max_terminated_count: 26,
                           min_terminated_count: 26
                         )

    agg_stat5 = Stats::AggActiveCallAccount.find_by! account_id: accounts[1].id, calls_time: Time.zone.parse('2021-04-09 11:00:00')
    expect(agg_stat5).to have_attributes(
                           avg_originated_count: 16,
                           max_originated_count: 16,
                           min_originated_count: 16,
                           avg_terminated_count: 27,
                           max_terminated_count: 27,
                           min_terminated_count: 27
                         )

    last_stats = Stats::AggActiveCallAccount.last(5)
    expect(last_stats.pluck(:id)).to match_array [agg_stat1.id, agg_stat2.id, agg_stat3.id, agg_stat4.id, agg_stat5.id]
  end

  it 'deletes stats' do
    expect { subject }.to change { Stats::ActiveCallAccount.count }.by(-stats.size)
    expect(Stats::ActiveCallAccount.where(id: stats.pluck(:id)).count).to eq 0
  end
end
