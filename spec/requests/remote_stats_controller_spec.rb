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

    it 'responds with correct data' do
      subject
      expect(response).to have_http_status(:success)
      expect(response_json).to match_array(
        [
          {
            key: "Node #{nodes[0].id}",
            values: [
              [active_call_stats[0].created_at.to_datetime.to_fs(:db),
               active_call_stats[0].count]
            ]
          },
          {
            key: "Node #{nodes[1].id}",
            values: [
              [active_call_stats[1].created_at.to_datetime.to_fs(:db),
               active_call_stats[1].count]
            ]
          }
        ]
      )
    end
  end
end
