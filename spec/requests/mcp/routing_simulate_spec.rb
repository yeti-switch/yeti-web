# frozen_string_literal: true

RSpec.describe 'MCP routing.simulate tool', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:token) { issue_access_token(admin: admin) }

  def call_tool(arguments)
    mcp_call(
      token: token.plaintext_token,
      method: 'tools/call',
      params: { name: 'routing.simulate', arguments: arguments }
    )
  end

  it 'returns isError with field name when src_number is missing' do
    call_tool('dst_number' => '+14155551234', 'remote_ip' => '1.2.3.4')
    body = JSON.parse(response.body)
    expect(body.dig('result', 'isError')).to be true
    expect(body.dig('result', 'content', 0, 'text')).to match(/src.?number/i)
  end

  it 'returns isError when remote_ip is missing' do
    call_tool('src_number' => '+442012345678', 'dst_number' => '+14155551234')
    body = JSON.parse(response.body)
    expect(body.dig('result', 'isError')).to be true
    expect(body.dig('result', 'content', 0, 'text')).to match(/remote.?ip/i)
  end

  it 'invokes Routing::SimulationForm and returns candidates + notices' do
    fake_form = instance_double(
      Routing::SimulationForm,
      save: true,
      debug: [],
      notices: ['auth matched nothing']
    )
    expect(Routing::SimulationForm).to receive(:new).and_return(fake_form)

    call_tool(
      'src_number' => '+442012345678',
      'dst_number' => '+14155551234',
      'remote_ip' => '1.2.3.4'
    )
    body = JSON.parse(response.body)
    text = body.dig('result', 'content', 0, 'text')
    payload = JSON.parse(text)
    expect(payload).to have_key('candidates')
    expect(payload['notices']).to eq(['auth matched nothing'])
  end
end
