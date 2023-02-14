# frozen_string_literal: true

RSpec.describe 'switch20.load_disconnect_code_refuse_overrides' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch20.load_disconnect_code_refuse_overrides()'
  end

  let!(:dpp) { create(:disconnect_policy) }
  let!(:dp_code) { create(:disconnect_policy_code, policy_id: dpp.id, code_id: DisconnectCode.where(namespace_id: DisconnectCode::NS_TM).first.id) }

  it 'responds with correct rows' do
    expect(subject.first).to have_key(:o_id)
    expect(subject.first).to have_key(:policy_id)
    expect(subject.first).to have_key(:o_code)
    expect(subject.first).to have_key(:o_reason)
    expect(subject.first).to have_key(:o_rewrited_code)
    expect(subject.first).to have_key(:o_rewrited_reason)
    expect(subject.first).to have_key(:o_silently_drop)
    expect(subject.first).to have_key(:o_store_cdr)
  end
end
