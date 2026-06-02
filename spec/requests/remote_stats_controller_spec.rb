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
end
