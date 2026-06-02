# frozen_string_literal: true

RSpec.describe RemoteStatsController do
  include_context :login_as_admin

  describe 'GET /remote_stats/nodes' do
    subject do
      get '/remote_stats/nodes.json'
    end

    let!(:nodes) { create_list(:node, 3) }
    let!(:active_call_stats) do
      [
        create(:stats_active_call, node: nodes[0], created_at: 1.hour.ago),
        create(:stats_active_call, node: nodes[1], created_at: 2.hours.ago)
      ]
    end

    # Mirror Stats::ActiveCall.to_stacked_chart's `(EXTRACT(EPOCH ...) * 1000)::bigint`.
    # EXTRACT returns numeric and the bigint cast rounds half away from zero, which
    # Rational#round matches exactly. Reload first so created_at carries the DB's
    # microsecond resolution (the in-memory value from `N.hours.ago` has nanoseconds
    # PostgreSQL never stored); `to_f` would add float drift that can flip the
    # rounding near a sub-millisecond boundary and make the spec flaky.
    def expected_x(stat)
      (stat.reload.created_at.to_r * 1000).round
    end

    it 'responds with correct data' do
      subject
      expect(response).to have_http_status(:success)
      expect(response_json).to match_array(
        [
          {
            key: "Node #{nodes[0].id}",
            values: [
              { x: expected_x(active_call_stats[0]),
                y: active_call_stats[0].count }
            ]
          },
          {
            key: "Node #{nodes[1].id}",
            values: [
              { x: expected_x(active_call_stats[1]),
                y: active_call_stats[1].count }
            ]
          }
        ]
      )
    end
  end

  describe 'GET /remote_stats/:id/node with hours window' do
    subject do
      get "/remote_stats/#{node.id}/node.json", params: params
    end

    let!(:node) { create(:node) }
    let!(:recent_stat) { create(:stats_active_call, node: node, created_at: 1.hour.ago) }
    let!(:old_stat) { create(:stats_active_call, node: node, created_at: 25.hours.ago) }

    def response_xs
      response_json.first[:values].map { |v| v[:x] }
    end

    context 'without hours param (default 24h)' do
      let(:params) { {} }

      it 'returns only points within the last 24 hours' do
        subject
        expect(response).to have_http_status(:success)
        expect(response_xs).to contain_exactly(recent_stat.reload.created_at.to_i * 1000)
      end
    end

    context 'with hours=720 (one month)' do
      let(:params) { { hours: 720 } }

      it 'includes older points within the window' do
        subject
        expect(response_xs).to contain_exactly(
          recent_stat.reload.created_at.to_i * 1000,
          old_stat.reload.created_at.to_i * 1000
        )
      end
    end

    context 'with a non-positive hours param' do
      let(:params) { { hours: '0' } }

      it 'falls back to the 24h default' do
        subject
        expect(response_xs).to contain_exactly(recent_stat.reload.created_at.to_i * 1000)
      end
    end
  end
end
