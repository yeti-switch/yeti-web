# frozen_string_literal: true

RSpec.describe BatchUpdateForm::NumberlistItem do
  let!(:lua_script) { create :lua_script }
  let!(:tag_action) { create :tag_action }
  let!(:routing_tag) { create :routing_tag }

  let(:assign_params) do
    {
      number_min_length: '4',
      number_max_length: '10',
      action_id: Routing::NumberlistItem::ACTION_ACCEPT.to_s,
      src_rewrite_rule: '^123',
      src_rewrite_result: '456',
      defer_src_rewrite: '1',
      dst_rewrite_rule: '^321',
      dst_rewrite_result: '654',
      defer_dst_rewrite: '0',
      tag_action_id: tag_action.id.to_s,
      tag_action_value: routing_tag.id.to_s,
      rewrite_ss_status_id: Equipment::StirShaken::Attestation::ATTESTATION_B.to_s,
      lua_script_id: lua_script.id.to_s,
      variables_json: '{"foo":"bar"}'
    }
  end

  subject do
    form = described_class.new(assign_params)
    form.valid?
    form
  end

  it { is_expected.to be_valid }
end
