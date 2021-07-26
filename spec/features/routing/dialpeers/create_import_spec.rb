# frozen_string_literal: true

RSpec.describe 'Create Dialpeer Imports' do
  subject do
    visit dialpeers_path
    click_action_item 'Import'
  end

  include_context :login_as_admin
  let!(:routing_group) { create(:routing_group) }
  let!(:contractor) { create(:vendor) }
  let!(:gateway) { create(:gateway, contractor: contractor) }
  let!(:dialpeer) { create(:dialpeer, dialpeer_attrs) }
  let!(:dialpeer_attrs) do
    {
      prefix: '123456',
      src_rewrite_rule: '4587',
      dst_rewrite_rule: '789',
      gateway: gateway,
      routing_group: routing_group,
      src_rewrite_result: '1145',
      dst_rewrite_result: '86554',
      vendor: contractor
    }
  end

  it 'has correct import form', js: true do
    subject

    expect(page).to have_field 'Col sep*', with: ',', exact: true
    expect(page).to have_field 'Row sep*', with: '', exact: true
    expect(page).to have_field 'Quote char*', with: '', exact: true

    expect(page).to have_field 'File', type: :file
    expect(page).to have_field 'Script', with: '', exact: true
  end

  context 'when dialpeer imports already exists' do
    let!(:import) { create(:importing_dialpeer, o_id: dialpeer.id) }

    it 'redirects to imports page' do
      subject
      expect(page).to have_flash_message('Please finish your previous import session.', type: :notice)
      expect(page).to have_current_path dialpeer_imports_path
      expect(page).to have_table_row(count: 1)
    end
  end
end
