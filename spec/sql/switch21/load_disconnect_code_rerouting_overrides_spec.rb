# frozen_string_literal: true

RSpec.describe 'switch21.load_disconnect_code_rerouting_overrides' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch21.load_disconnect_code_rerouting_overrides()'
  end

  let!(:dpp) { create(:disconnect_policy) }
  let(:disconnect_code) { create(:disconnect_code, :sip) }
  let!(:dp_code) { create(:disconnect_policy_code, policy_id: dpp.id, code: disconnect_code) }

  it 'responds with correct rows' do
    expect(subject.first).to have_key(:policy_id)
    expect(subject.first).to have_key(:received_code)
    expect(subject.first).to have_key(:stop_rerouting)
  end
end
