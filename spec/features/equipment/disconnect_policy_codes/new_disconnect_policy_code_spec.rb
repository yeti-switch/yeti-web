# frozen_string_literal: true

RSpec.describe 'Create new Disconnect Policy Code', type: :feature, js: true do
  subject do
    aa_form.submit
  end

  active_admin_form_for DisconnectPolicyCode, 'new'
  include_context :login_as_admin
  let!(:disconnect_policy) { FactoryBot.create(:disconnect_policy) }
  let!(:disconnect_code) { FactoryBot.create(:disconnect_code, :sip) }

  before do
    visit new_disconnect_policy_code_path

    aa_form.select_chosen 'Policy', disconnect_policy.name
    aa_form.select_chosen 'Code', disconnect_code.display_name
  end

  it 'creates record' do
    subject
    record = DisconnectPolicyCode.last
    expect(record).to be_present
    expect(record).to have_attributes(
      code_id: disconnect_code.id,
      policy_id: disconnect_policy.id,
      stop_hunting: true,
      pass_reason_to_originator: false,
      rewrited_code: nil,
      rewrited_reason: ''
    )
  end

  include_examples :changes_records_qty_of, DisconnectPolicyCode, by: 1
  include_examples :shows_flash_message, :notice, 'Disconnect policy code was successfully created.'
end
