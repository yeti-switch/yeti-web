# frozen_string_literal: true

RSpec.describe StatsAggregation::ActiveCallTermGateway, freeze_time: Time.zone.parse('2021-04-10 12:00:00') do
  subject do
    described_class.call
  end

  let!(:gateways) do
    FactoryBot.create_list(:gateway, 3)
  end

  let!(:stats) do
    [
      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 10, created_at: Time.zone.parse('2021-04-01 00:01:10')),

      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 11, created_at: Time.zone.parse('2021-04-09 10:00:00')),

      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 10, created_at: Time.zone.parse('2021-04-09 11:00:00')),
      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 50, created_at: Time.zone.parse('2021-04-09 11:31:18')),
      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 6, created_at: Time.zone.parse('2021-04-09 11:59:59')),

      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[1], count: 15, created_at: Time.zone.parse('2021-04-09 02:34:49')),

      FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[1], count: 16, created_at: Time.zone.parse('2021-04-09 11:00:01'))
    ]
  end

  before do
    # not aggregated because created later than 1 day ago
    FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[0], count: 100, created_at: Time.zone.parse('2021-04-09 12:00:00'))
    FactoryBot.create(:stats_active_call_term_gw, gateway: gateways[2], count: 101, created_at: Time.zone.parse('2021-04-10 00:00:00'))
  end

  it 'creates correct aggregated active call stats' do
    expect { subject }.to change { Stats::AggActiveCallTermGateway.count }.by(5)

    agg_stat1 = Stats::AggActiveCallTermGateway.find_by! gateway_id: gateways[0].id, calls_time: Time.zone.parse('2021-04-01 00:00:00')
    expect(agg_stat1).to have_attributes(avg_count: 10, max_count: 10, min_count: 10)

    agg_stat2 = Stats::AggActiveCallTermGateway.find_by! gateway_id: gateways[0].id, calls_time: Time.zone.parse('2021-04-09 10:00:00')
    expect(agg_stat2).to have_attributes(avg_count: 11, max_count: 11, min_count: 11)

    agg_stat3 = Stats::AggActiveCallTermGateway.find_by! gateway_id: gateways[0].id, calls_time: Time.zone.parse('2021-04-09 11:00:00')
    expect(agg_stat3).to have_attributes(avg_count: 22, max_count: 50, min_count: 6)

    agg_stat4 = Stats::AggActiveCallTermGateway.find_by! gateway_id: gateways[1].id, calls_time: Time.zone.parse('2021-04-09 02:00:00')
    expect(agg_stat4).to have_attributes(avg_count: 15, max_count: 15, min_count: 15)

    agg_stat5 = Stats::AggActiveCallTermGateway.find_by! gateway_id: gateways[1].id, calls_time: Time.zone.parse('2021-04-09 11:00:00')
    expect(agg_stat5).to have_attributes(avg_count: 16, max_count: 16, min_count: 16)

    last_stats = Stats::AggActiveCallTermGateway.last(5)
    expect(last_stats.pluck(:id)).to match_array [agg_stat1.id, agg_stat2.id, agg_stat3.id, agg_stat4.id, agg_stat5.id]
  end

  it 'deletes stats' do
    expect { subject }.to change { Stats::ActiveCallTermGateway.count }.by(-stats.size)
    expect(Stats::ActiveCallTermGateway.where(id: stats.pluck(:id)).count).to eq 0
  end
end
