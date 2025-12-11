# frozen_string_literal: true

RSpec.describe 'switch22.load_disconnect_code_refuse_overrides' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_disconnect_code_refuse_overrides()'
  end

  let!(:dpp) { create(:disconnect_policy) }
  let(:disconnect_code) { create(:disconnect_code, :tm) }
  let!(:dp_code) { create(:disconnect_policy_code, policy_id: dpp.id, code: disconnect_code) }

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
