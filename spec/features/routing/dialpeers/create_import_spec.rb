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

  context 'apply unique columns', js: true do
    let!(:gateway_group) { create(:gateway_group, vendor: contractor) }
    let!(:dialpeer_1) { create(:dialpeer, dialpeer_1_attrs) }
    let(:dialpeer_1_attrs) do
      {
        prefix: '1',
        gateway: gateway,
        gateway_group: nil,

        src_rewrite_rule: '4587',
        dst_rewrite_rule: '789',
        routing_group: routing_group,
        src_rewrite_result: '1145',
        dst_rewrite_result: '86554',
        vendor: contractor
      }
    end
    let!(:dialpeer_2) { create(:dialpeer, dialpeer_2_attrs) }
    let(:dialpeer_2_attrs) do
      {
        prefix: '123',
        gateway: nil,
        gateway_group: gateway_group,

        src_rewrite_rule: '4587',
        dst_rewrite_rule: '789',
        routing_group: routing_group,
        src_rewrite_result: '1145',
        dst_rewrite_result: '86554',
        vendor: contractor
      }
    end
    let!(:import_1) { create(:importing_dialpeer, o_id: nil, prefix: 1, gateway_id: gateway.id, gateway_group: nil) }
    let!(:import_2) { create(:importing_dialpeer, o_id: nil, prefix: 123, gateway_id: nil, gateway_group_id: gateway_group.id) }
    let!(:import_3) { create(:importing_dialpeer, o_id: nil, prefix: 123, gateway_id: 2, gateway_group: nil) }
    let!(:import_4) { create(:importing_dialpeer, o_id: nil, prefix: 123, gateway_id: 3, gateway_group: nil) }

    subject do
      super()
      page.find('#collection_selection_toggle_all').set(true)
      click_on 'Apply unique columns'
      fill_in_chosen 'changes[unique_columns][]', with: :prefix, multiple: true, ajax: false
      fill_in_chosen 'changes[unique_columns][]', with: :gateway_id, multiple: true, ajax: false
      fill_in_chosen 'changes[unique_columns][]', with: :gateway_group_id, multiple: true, ajax: false
      click_on 'OK'
    end

    it 'should fill correct o_id for imported data' do
      expect { subject }.to change {
        import_1.reload.o_id
      }.to(dialpeer_1.id)
        .and change {
               import_2.reload.o_id
             }.to(dialpeer_2.id)
    end
  end
end
