# frozen_string_literal: true

RSpec.describe 'switch22.load_disconnect_code_rerouting_overrides' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_disconnect_code_rerouting_overrides()'
  end

  let!(:dpp) { create(:disconnect_policy) }
  let!(:dp_code) { create(:disconnect_policy_code, policy_id: dpp.id, code_id: DisconnectCode.where(namespace_id: DisconnectCode::NS_SIP).first.id) }

  it 'responds with correct rows' do
    expect(subject.first).to have_key(:policy_id)
    expect(subject.first).to have_key(:received_code)
    expect(subject.first).to have_key(:stop_rerouting)
  end
end
