# frozen_string_literal: true

RSpec.describe 'switch22.load_disconnect_code_rewrite_overrides' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_disconnect_code_rewrite_overrides()'
  end

  let!(:dpp) { create(:disconnect_policy) }
  let(:disconnect_code) { create(:disconnect_code, :sip) }
  let!(:dp_code) { create(:disconnect_policy_code, policy_id: dpp.id, code: disconnect_code) }

  it 'responds with correct rows' do
    expect(subject.first).to have_key(:o_code)
    expect(subject.first).to have_key(:o_pass_reason_to_originator)
    expect(subject.first).to have_key(:o_policy_id)
    expect(subject.first).to have_key(:o_reason)
    expect(subject.first).to have_key(:o_rewrited_code)
    expect(subject.first).to have_key(:o_rewrited_reason)
  end
end
